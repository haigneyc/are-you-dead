# 06 - API Design

[← Back to PRD](../PRD.md) | [← Previous: Database Schema](05-database-schema.md)

---

## Overview

The API consists of:
1. **Client API** - Flutter app ↔ Supabase (direct via supabase-flutter)
2. **Edge Functions** - Server-side logic for alerts and scheduled tasks

---

## Client API (Supabase Flutter)

The Flutter app communicates directly with Supabase using the `supabase_flutter` package. No custom REST API needed.

### Authentication

```dart
// Sign up
final response = await supabase.auth.signUp(
  email: email,
  password: password,
);

// Sign in
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Sign out
await supabase.auth.signOut();

// Password reset
await supabase.auth.resetPasswordForEmail(email);

// Get current user
final user = supabase.auth.currentUser;

// Listen to auth changes
supabase.auth.onAuthStateChange.listen((data) {
  final session = data.session;
  // Handle auth state
});
```

### User Profile

```dart
// Create profile (after signup)
await supabase.from('users').insert({
  'id': userId,
  'email': email,
  'display_name': name,
  'check_in_interval_hours': 48,
});

// Get profile
final profile = await supabase
  .from('users')
  .select()
  .eq('id', userId)
  .single();

// Update profile
await supabase.from('users').update({
  'display_name': newName,
  'check_in_interval_hours': newInterval,
  'fcm_token': token,
}).eq('id', userId);

// Delete account
await supabase.from('users').delete().eq('id', userId);
await supabase.auth.admin.deleteUser(userId);
```

### Check-In

```dart
// Perform check-in (using database function)
await supabase.rpc('perform_check_in', params: {
  'p_user_id': userId,
});

// Or manually:
await supabase.from('users').update({
  'last_check_in_at': DateTime.now().toIso8601String(),
  'next_check_in_due': nextDue.toIso8601String(),
}).eq('id', userId);

await supabase.from('check_in_history').insert({
  'user_id': userId,
  'was_on_time': true,
});

// Get check-in history
final history = await supabase
  .from('check_in_history')
  .select()
  .eq('user_id', userId)
  .order('checked_in_at', ascending: false)
  .limit(10);
```

### Emergency Contacts

```dart
// List contacts
final contacts = await supabase
  .from('emergency_contacts')
  .select()
  .eq('user_id', userId)
  .order('priority');

// Add contact
await supabase.from('emergency_contacts').insert({
  'user_id': userId,
  'name': name,
  'phone': phone,
  'email': email,
  'priority': priority,
});

// Update contact
await supabase.from('emergency_contacts').update({
  'name': name,
  'phone': phone,
  'email': email,
}).eq('id', contactId);

// Delete contact
await supabase
  .from('emergency_contacts')
  .delete()
  .eq('id', contactId);

// Reorder priorities
await supabase.from('emergency_contacts').update({
  'priority': newPriority,
}).eq('id', contactId);
```

### Alert History

```dart
// Get alerts sent for user
final alerts = await supabase
  .from('alerts_sent')
  .select('*, emergency_contacts(name)')
  .eq('user_id', userId)
  .order('sent_at', ascending: false)
  .limit(20);
```

---

## Supabase Edge Functions

### 1. `check-missed-checkins`

**Purpose**: Detect users who missed their check-in and trigger alerts.

**Trigger**: Cron job every 5 minutes

**Location**: `supabase/functions/check-missed-checkins/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
// Secret key (Supabase auto-injects as SERVICE_ROLE_KEY)
const supabaseSecretKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req) => {
  // Verify cron secret (optional security)
  const authHeader = req.headers.get("Authorization");
  if (authHeader !== `Bearer ${Deno.env.get("CRON_SECRET")}`) {
    return new Response("Unauthorized", { status: 401 });
  }

  const supabase = createClient(supabaseUrl, supabaseSecretKey);

  // Get overdue users (using database function)
  const { data: overdueUsers, error } = await supabase
    .rpc("get_overdue_users");

  if (error) {
    console.error("Error fetching overdue users:", error);
    return new Response(JSON.stringify({ error }), { status: 500 });
  }

  console.log(`Found ${overdueUsers.length} overdue users`);

  // Process each overdue user
  for (const user of overdueUsers) {
    // Get their emergency contacts
    const { data: contacts } = await supabase
      .from("emergency_contacts")
      .select("*")
      .eq("user_id", user.user_id)
      .order("priority");

    // Trigger alerts for each contact
    for (const contact of contacts || []) {
      // Call send-alert function
      await fetch(`${supabaseUrl}/functions/v1/send-alert`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${supabaseSecretKey}`,
        },
        body: JSON.stringify({
          user_id: user.user_id,
          user_name: user.display_name || user.email,
          last_check_in: user.last_check_in_at,
          contact_id: contact.id,
          contact_name: contact.name,
          contact_phone: contact.phone,
          contact_email: contact.email,
        }),
      });
    }
  }

  return new Response(
    JSON.stringify({ processed: overdueUsers.length }),
    { headers: { "Content-Type": "application/json" } }
  );
});
```

**Cron Setup** (in Supabase dashboard or via pg_cron):

```sql
SELECT cron.schedule(
  'check-missed-checkins',
  '*/5 * * * *',  -- Every 5 minutes
  $$
  SELECT net.http_post(
    url := 'https://YOUR_PROJECT.supabase.co/functions/v1/check-missed-checkins',
    headers := '{"Authorization": "Bearer YOUR_CRON_SECRET"}'::jsonb
  );
  $$
);
```

---

### 2. `send-alert`

**Purpose**: Send SMS and email alerts to an emergency contact.

**Trigger**: HTTP POST from `check-missed-checkins`

**Location**: `supabase/functions/send-alert/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const TWILIO_ACCOUNT_SID = Deno.env.get("TWILIO_ACCOUNT_SID")!;
const TWILIO_AUTH_TOKEN = Deno.env.get("TWILIO_AUTH_TOKEN")!;
const TWILIO_PHONE_NUMBER = Deno.env.get("TWILIO_PHONE_NUMBER")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;

interface AlertRequest {
  user_id: string;
  user_name: string;
  last_check_in: string;
  contact_id: string;
  contact_name: string;
  contact_phone: string;
  contact_email?: string;
}

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const body: AlertRequest = await req.json();
  const results = { sms: null, email: null };

  // Format last check-in date
  const lastActive = new Date(body.last_check_in).toLocaleDateString("en-US", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });

  const message = `${body.user_name} hasn't checked in on their safety app "Are You Dead?" Please check on them. Last active: ${lastActive}`;

  // Send SMS via Twilio
  try {
    const twilioResponse = await fetch(
      `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": `Basic ${btoa(`${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}`)}`,
        },
        body: new URLSearchParams({
          To: body.contact_phone,
          From: TWILIO_PHONE_NUMBER,
          Body: message,
        }),
      }
    );

    const twilioData = await twilioResponse.json();

    // Log SMS alert
    await supabase.from("alerts_sent").insert({
      user_id: body.user_id,
      contact_id: body.contact_id,
      alert_type: "sms",
      status: twilioResponse.ok ? "sent" : "failed",
      external_id: twilioData.sid,
      error_message: twilioResponse.ok ? null : twilioData.message,
    });

    results.sms = twilioResponse.ok ? "sent" : "failed";
  } catch (error) {
    console.error("SMS error:", error);
    results.sms = "error";
  }

  // Send email via Resend (if email provided)
  if (body.contact_email) {
    try {
      const emailResponse = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${RESEND_API_KEY}`,
        },
        body: JSON.stringify({
          from: "Are You Dead? <alerts@areyoudead.app>",
          to: body.contact_email,
          subject: `Safety Check Required - ${body.user_name}`,
          html: `
            <h2>Safety Check Required</h2>
            <p>${message}</p>
            <p>If you cannot reach ${body.user_name}, please consider contacting local authorities for a wellness check.</p>
            <hr>
            <p style="color: #666; font-size: 12px;">
              This alert was sent by the "Are You Dead?" safety app.
              ${body.user_name} added you as an emergency contact.
            </p>
          `,
        }),
      });

      const emailData = await emailResponse.json();

      // Log email alert
      await supabase.from("alerts_sent").insert({
        user_id: body.user_id,
        contact_id: body.contact_id,
        alert_type: "email",
        status: emailResponse.ok ? "sent" : "failed",
        external_id: emailData.id,
        error_message: emailResponse.ok ? null : emailData.message,
      });

      results.email = emailResponse.ok ? "sent" : "failed";
    } catch (error) {
      console.error("Email error:", error);
      results.email = "error";
    }
  }

  return new Response(JSON.stringify(results), {
    headers: { "Content-Type": "application/json" },
  });
});
```

---

### 3. `schedule-reminders`

**Purpose**: Send push notification reminders to users approaching their deadline.

**Trigger**: Cron job every hour

**Location**: `supabase/functions/schedule-reminders/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const now = new Date();

  // Find users due in ~24h, ~6h, ~1h
  const windows = [
    { hours: 24, message: "Check in tomorrow to let your contacts know you're OK" },
    { hours: 6, message: "Check-in due in 6 hours" },
    { hours: 1, message: "Last chance! Check in within 1 hour" },
  ];

  for (const window of windows) {
    const windowStart = new Date(now.getTime() + (window.hours - 0.5) * 60 * 60 * 1000);
    const windowEnd = new Date(now.getTime() + (window.hours + 0.5) * 60 * 60 * 1000);

    const { data: users } = await supabase
      .from("users")
      .select("id, fcm_token")
      .not("fcm_token", "is", null)
      .gte("next_check_in_due", windowStart.toISOString())
      .lt("next_check_in_due", windowEnd.toISOString());

    for (const user of users || []) {
      // Send FCM notification
      await sendFCMNotification(user.fcm_token, {
        title: "Are You Dead?",
        body: window.message,
      });
    }

    console.log(`Sent ${users?.length || 0} reminders for ${window.hours}h window`);
  }

  return new Response("OK");
});

async function sendFCMNotification(token: string, notification: { title: string; body: string }) {
  const FCM_SERVER_KEY = Deno.env.get("FCM_SERVER_KEY")!;

  await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `key=${FCM_SERVER_KEY}`,
    },
    body: JSON.stringify({
      to: token,
      notification,
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    }),
  });
}
```

---

## API Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "CONTACT_LIMIT_REACHED",
    "message": "Maximum of 5 emergency contacts allowed",
    "details": {
      "current_count": 5,
      "max_allowed": 5
    }
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or expired session |
| `FORBIDDEN` | 403 | Action not allowed (RLS) |
| `NOT_FOUND` | 404 | Resource doesn't exist |
| `CONTACT_LIMIT_REACHED` | 400 | Max 5 contacts |
| `INVALID_PHONE` | 400 | Phone number format invalid |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Server error |

---

## Environment Variables

### Edge Functions

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | Yes (auto) |
| `SUPABASE_SERVICE_ROLE_KEY` | Secret key (bypasses RLS) | Yes (auto) |
| `TWILIO_ACCOUNT_SID` | Twilio account ID | Yes |
| `TWILIO_AUTH_TOKEN` | Twilio auth token | Yes |
| `TWILIO_PHONE_NUMBER` | Twilio sending number | Yes |
| `RESEND_API_KEY` | Resend API key | Yes |
| `FCM_SERVER_KEY` | Firebase server key | Yes |
| `CRON_SECRET` | Secret for cron auth | Yes |

### Setting Secrets

```bash
supabase secrets set TWILIO_ACCOUNT_SID=xxx
supabase secrets set TWILIO_AUTH_TOKEN=xxx
supabase secrets set TWILIO_PHONE_NUMBER=+1234567890
supabase secrets set RESEND_API_KEY=xxx
supabase secrets set FCM_SERVER_KEY=xxx
supabase secrets set CRON_SECRET=xxx
```

---

[Next: UI/UX Specification →](07-ui-ux-spec.md)
