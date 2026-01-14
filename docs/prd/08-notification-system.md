# 08 - Notification System

[← Back to PRD](../PRD.md) | [← Previous: UI/UX Spec](07-ui-ux-spec.md)

---

## Overview

The notification system has two distinct channels:

1. **Push Notifications** → To the user (reminders)
2. **Emergency Alerts** → To contacts (SMS + email)

```
┌─────────────────────────────────────────────────────────────┐
│                    NOTIFICATION FLOW                         │
│                                                             │
│  User sets check-in interval (e.g., 48 hours)               │
│                      │                                       │
│                      ▼                                       │
│  ┌─────────────────────────────────────┐                    │
│  │     PUSH NOTIFICATIONS (TO USER)     │                    │
│  │                                      │                    │
│  │  T-24h: "Check in tomorrow..."       │                    │
│  │  T-6h:  "Check-in due in 6 hours"    │                    │
│  │  T-1h:  "Last chance! 1 hour left"   │                    │
│  │  T+0h:  "You missed your check-in"   │                    │
│  └─────────────────────────────────────┘                    │
│                      │                                       │
│                      ▼                                       │
│  ┌─────────────────────────────────────┐                    │
│  │        GRACE PERIOD (1 HOUR)         │                    │
│  │                                      │                    │
│  │  User can still check in and         │                    │
│  │  prevent alerts from sending         │                    │
│  └─────────────────────────────────────┘                    │
│                      │                                       │
│                      ▼                                       │
│  ┌─────────────────────────────────────┐                    │
│  │   EMERGENCY ALERTS (TO CONTACTS)     │                    │
│  │                                      │                    │
│  │  SMS via Twilio                      │                    │
│  │  Email via Resend                    │                    │
│  └─────────────────────────────────────┘                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Push Notifications (To User)

### Notification Schedule

| Trigger | Title | Body | Priority |
|---------|-------|------|----------|
| 24h before | Are You Dead? | Check in tomorrow to let your contacts know you're OK | Normal |
| 6h before | Are You Dead? | Check-in due in 6 hours | High |
| 1h before | Are You Dead? | Last chance! Check in within 1 hour | High |
| Overdue | Are You Dead? | You missed your check-in. Your contacts will be notified soon. | Critical |
| Alert sent | Are You Dead? | Your emergency contacts have been notified. | Normal |

### Implementation (Firebase Cloud Messaging)

```dart
// notification_service.dart

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,  // For overdue alerts
    );

    // Get FCM token
    final token = await _fcm.getToken();
    // Save token to Supabase user profile

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
    );
  }

  void _handleMessageOpen(RemoteMessage message) {
    // Navigate to check-in screen
    navigatorKey.currentState?.pushNamed('/home');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'check_in_reminders',
      'Check-in Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await FlutterLocalNotificationsPlugin().show(
      0,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }
}
```

### FCM Payload Structure

```json
{
  "to": "<FCM_TOKEN>",
  "notification": {
    "title": "Are You Dead?",
    "body": "Check-in due in 6 hours"
  },
  "data": {
    "type": "reminder",
    "hours_remaining": "6",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "android": {
    "priority": "high",
    "notification": {
      "channel_id": "check_in_reminders",
      "sound": "default"
    }
  },
  "apns": {
    "payload": {
      "aps": {
        "sound": "default",
        "badge": 1
      }
    }
  }
}
```

### Notification Preferences

Users can customize:

| Setting | Options | Default |
|---------|---------|---------|
| Reminders enabled | On/Off | On |
| 24h reminder | On/Off | On |
| 6h reminder | On/Off | On |
| 1h reminder | On/Off | On |
| Sound | On/Off | On |
| Vibration | On/Off | On |

---

## Emergency Alerts (To Contacts)

### Alert Triggering Logic

```typescript
// Pseudocode for check-missed-checkins function

function checkMissedCheckins() {
  // Find users where:
  // 1. next_check_in_due has passed
  // 2. Grace period (1 hour) has passed
  // 3. No alert sent in last 24 hours

  const overdueUsers = db.query(`
    SELECT * FROM users
    WHERE next_check_in_due IS NOT NULL
      AND NOW() > next_check_in_due + INTERVAL '1 hour'
      AND NOT EXISTS (
        SELECT 1 FROM alerts_sent
        WHERE user_id = users.id
          AND sent_at > NOW() - INTERVAL '24 hours'
      )
  `);

  for (const user of overdueUsers) {
    const contacts = getEmergencyContacts(user.id);

    for (const contact of contacts) {
      sendSMS(contact.phone, formatSMSMessage(user));

      if (contact.email) {
        sendEmail(contact.email, formatEmailMessage(user));
      }

      logAlert(user.id, contact.id, 'sent');
    }
  }
}
```

### SMS Alert

**Via Twilio**

> **Note**: Twilio requires A2P 10DLC registration for US SMS. This involves registering your brand and campaign, which requires a live website and business information. See https://www.twilio.com/docs/messaging/compliance/a2p-10dlc

```
To: +1 (555) 123-4567
From: +1 (555) 000-0000

Alex hasn't checked in on their safety app "Are You Dead?" in 2 days. Please check on them.

Last active: Saturday, January 10, 2026

If you can't reach Alex, consider requesting a wellness check from local authorities.
```

**Character Limit**: ~300 characters (2 SMS segments)

**Cost**: ~$0.015 per alert (2 segments × $0.0075)

### Email Alert

**Via Resend**

> **Note**: Resend requires a verified domain to send to arbitrary recipients. During development, use `onboarding@resend.dev` which can only send to the account owner's email. For production, verify your domain at https://resend.com/domains.

```
From: Are You Dead? <alerts@areyoudead.site>
To: mom@email.com
Subject: Safety Check Required - Alex

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SAFETY CHECK REQUIRED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Alex hasn't checked in on their safety app in 2 days.

Last active: Saturday, January 10, 2026

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT TO DO:

1. Try to contact Alex directly (call, text, visit)
2. If you can't reach them, consider contacting local
   authorities for a wellness check

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This alert was sent by the "Are You Dead?" safety app.
Alex added you as an emergency contact.

If you have questions, reply to this email.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Alert Message Personalization

| Variable | Source | Example |
|----------|--------|---------|
| `{name}` | user.display_name or user.email | "Alex" |
| `{days_overdue}` | Calculated | "2 days" |
| `{last_active}` | user.last_check_in_at | "Saturday, January 10, 2026" |
| `{contact_name}` | contact.name | "Mom" |

---

## Duplicate Prevention

### Rules

1. **No repeat alerts within 24 hours** for the same user
2. **No duplicate SMS/email** to the same contact for the same incident
3. **Check-in cancels pending alerts** - if user checks in during grace period

### Implementation

```sql
-- Check if alert already sent recently
SELECT COUNT(*) FROM alerts_sent
WHERE user_id = $1
  AND sent_at > NOW() - INTERVAL '24 hours'
  AND status = 'sent';

-- If count > 0, skip sending
```

---

## Alert States

```
┌─────────┐     ┌─────────┐     ┌─────────┐
│ Pending │────▶│  Sent   │────▶│  Acked  │
└─────────┘     └─────────┘     └─────────┘
     │                               ▲
     │          ┌─────────┐          │
     └─────────▶│ Failed  │──────────┘
                └─────────┘   (retry)
```

| State | Description |
|-------|-------------|
| `pending` | Alert queued, not yet sent |
| `sent` | Successfully delivered to Twilio/Resend |
| `failed` | Delivery failed (will retry) |

### Retry Logic

```typescript
// Retry failed alerts up to 3 times with exponential backoff
const MAX_RETRIES = 3;
const BACKOFF_MS = [60000, 300000, 900000]; // 1m, 5m, 15m

async function retryFailedAlerts() {
  const failedAlerts = await db.query(`
    SELECT * FROM alerts_sent
    WHERE status = 'failed'
      AND retry_count < 3
      AND last_retry_at < NOW() - INTERVAL '1 minute'
  `);

  for (const alert of failedAlerts) {
    const backoff = BACKOFF_MS[alert.retry_count] || BACKOFF_MS[2];

    if (Date.now() - alert.last_retry_at > backoff) {
      await retrySendAlert(alert);
    }
  }
}
```

---

## Notification Channels (Android)

```dart
// main.dart - Create notification channels

Future<void> createNotificationChannels() async {
  const androidPlugin = AndroidFlutterLocalNotificationsPlugin();

  // Reminder channel
  await androidPlugin.createNotificationChannel(
    const AndroidNotificationChannel(
      'check_in_reminders',
      'Check-in Reminders',
      description: 'Reminders to check in',
      importance: Importance.high,
    ),
  );

  // Urgent channel (for overdue)
  await androidPlugin.createNotificationChannel(
    const AndroidNotificationChannel(
      'urgent_alerts',
      'Urgent Alerts',
      description: 'Critical alerts when check-in is overdue',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    ),
  );
}
```

---

## iOS Configuration

### Info.plist

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

### Capabilities

- Push Notifications
- Background Modes → Remote notifications
- Critical Alerts (requires Apple approval for overdue notifications)

---

## Testing Notifications

### Test Scenarios

| Scenario | Expected Result |
|----------|-----------------|
| New user, 24h before deadline | Push notification received |
| 6h before deadline | Push notification received |
| 1h before deadline | Push notification received |
| User checks in before deadline | No alert sent |
| User misses deadline + grace period | SMS + email sent to all contacts |
| User checks in during grace period | Alert canceled |
| Contact has no email | SMS only |
| SMS fails | Logged as failed, retried |
| Second miss within 24h | No duplicate alert |

### Test Mode

For development/testing:

```typescript
// Edge function env var
TEST_MODE=true

// In test mode:
// - SMS/email go to test numbers/emails only
// - Check-in interval can be set to minutes
// - Grace period reduced to 1 minute
```

---

## Cost Estimation

### Per-User Monthly Cost

| Scenario | Push | SMS | Email | Total |
|----------|------|-----|-------|-------|
| Normal (no misses) | Free | $0 | $0 | $0 |
| 1 missed check-in | Free | $0.015 | Free | $0.015 |
| 4 missed check-ins | Free | $0.06 | Free | $0.06 |

### Platform Costs

| Service | Free Tier | Paid Rate |
|---------|-----------|-----------|
| Firebase FCM | 1M/month | Free |
| Twilio SMS | None | $0.0075/segment |
| Resend Email | 3K/month | $0.001/email after |

### Monthly Budget (10K users)

Assuming 5% miss rate, 1 contact per user:
- Push: Free
- SMS: 500 misses × $0.015 = $7.50
- Email: 500 misses × $0.001 = $0.50
- **Total: ~$8/month**

---

[Next: Launch Checklist →](09-launch-checklist.md)
