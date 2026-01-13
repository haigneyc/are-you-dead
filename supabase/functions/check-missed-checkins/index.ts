import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { sendFCMNotification } from "../_shared/fcm.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseSecretKey = Deno.env.get("SECRET_API_KEY")!;
const cronSecret = Deno.env.get("CRON_SECRET");

interface OverdueUser {
  user_id: string;
  email: string;
  display_name: string | null;
  last_check_in_at: string;
  hours_overdue: number;
}

interface EmergencyContact {
  id: string;
  name: string;
  phone: string;
  email: string | null;
  priority: number;
}

serve(async (req) => {
  // Verify cron secret if set (use X-Cron-Secret header to avoid conflict with Supabase JWT)
  if (cronSecret) {
    const cronHeader = req.headers.get("X-Cron-Secret");
    if (cronHeader !== cronSecret) {
      return new Response("Unauthorized", { status: 401 });
    }
  }

  const supabase = createClient(supabaseUrl, supabaseSecretKey);

  try {
    // Get overdue users using database function
    const { data: overdueUsers, error } = await supabase.rpc("get_overdue_users");

    if (error) {
      console.error("Error fetching overdue users:", error);
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    console.log(`Found ${overdueUsers?.length || 0} overdue users`);

    const results: Array<{ userId: string; contactsAlerted: number }> = [];

    // Process each overdue user
    for (const user of (overdueUsers as OverdueUser[]) || []) {
      // Get their emergency contacts
      const { data: contacts } = await supabase
        .from("emergency_contacts")
        .select("*")
        .eq("user_id", user.user_id)
        .order("priority");

      let contactsAlerted = 0;

      // Trigger alerts for each contact
      for (const contact of (contacts as EmergencyContact[]) || []) {
        try {
          const response = await fetch(`${supabaseUrl}/functions/v1/send-alert`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${supabaseSecretKey}`,
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

          if (response.ok) {
            contactsAlerted++;
          } else {
            console.error(`Failed to alert contact ${contact.id}`);
          }
        } catch (e) {
          console.error(`Error alerting contact ${contact.id}:`, e);
        }
      }

      // Send push notification to user that alerts were sent
      const { data: userData } = await supabase
        .from("users")
        .select("fcm_token")
        .eq("id", user.user_id)
        .single();

      if (userData?.fcm_token && contactsAlerted > 0) {
        await sendFCMNotification({
          token: userData.fcm_token,
          notification: {
            title: "Alert Sent",
            body: "Your emergency contacts have been notified. Check in now to let them know you're OK.",
          },
          data: {
            urgent: "true",
            route: "/",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: {
            priority: "high",
            notification: {
              channel_id: "urgent_alerts",
            },
          },
        });
      }

      results.push({ userId: user.user_id, contactsAlerted });
    }

    return new Response(JSON.stringify({ processed: results.length, results }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("Error:", e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
