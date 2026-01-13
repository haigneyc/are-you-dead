import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { sendFCMNotification } from "../_shared/fcm.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseSecretKey = Deno.env.get("SECRET_API_KEY")!;
const cronSecret = Deno.env.get("CRON_SECRET");

interface ReminderWindow {
  hours: number;
  title: string;
  message: string;
  urgent: boolean;
}

const REMINDER_WINDOWS: ReminderWindow[] = [
  {
    hours: 24,
    title: "Check-in Reminder",
    message: "Check in tomorrow to let your contacts know you're OK",
    urgent: false,
  },
  {
    hours: 6,
    title: "Check-in Due Soon",
    message: "Your check-in is due in about 6 hours",
    urgent: false,
  },
  {
    hours: 1,
    title: "Final Reminder",
    message: "Check in within 1 hour to avoid alerting your contacts",
    urgent: true,
  },
];

serve(async (req) => {
  // Verify cron secret if set (use X-Cron-Secret header to avoid conflict with Supabase JWT)
  if (cronSecret) {
    const cronHeader = req.headers.get("X-Cron-Secret");
    if (cronHeader !== cronSecret) {
      return new Response("Unauthorized", { status: 401 });
    }
  }

  const supabase = createClient(supabaseUrl, supabaseSecretKey);
  const now = new Date();
  const results: Array<{ window: number; usersSent: number; errors: number }> = [];

  for (const window of REMINDER_WINDOWS) {
    // Calculate time window (30 min before and after target time)
    const windowStartMs = now.getTime() + (window.hours - 0.5) * 60 * 60 * 1000;
    const windowEndMs = now.getTime() + (window.hours + 0.5) * 60 * 60 * 1000;
    const windowStart = new Date(windowStartMs).toISOString();
    const windowEnd = new Date(windowEndMs).toISOString();

    // Find users with check-in due in this window who have FCM tokens
    const { data: users, error } = await supabase
      .from("users")
      .select("id, fcm_token, display_name")
      .not("fcm_token", "is", null)
      .gte("next_check_in_due", windowStart)
      .lt("next_check_in_due", windowEnd);

    if (error) {
      console.error(`Error querying ${window.hours}h window:`, error);
      continue;
    }

    let sentCount = 0;
    let errorCount = 0;

    for (const user of users || []) {
      if (!user.fcm_token) continue;

      const result = await sendFCMNotification({
        token: user.fcm_token,
        notification: {
          title: window.title,
          body: window.message,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          urgent: window.urgent.toString(),
          route: "/",
        },
        android: {
          priority: window.urgent ? "high" : "normal",
          notification: {
            channel_id: window.urgent ? "urgent_alerts" : "check_in_reminders",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: window.urgent ? "default" : undefined,
              badge: 1,
            },
          },
        },
      });

      if (result.success) {
        sentCount++;
      } else {
        errorCount++;
        console.error(`Failed to send to user ${user.id}: ${result.error}`);
      }
    }

    console.log(`Sent ${sentCount} reminders for ${window.hours}h window (${errorCount} errors)`);
    results.push({ window: window.hours, usersSent: sentCount, errors: errorCount });
  }

  return new Response(JSON.stringify({ results }), {
    headers: { "Content-Type": "application/json" },
  });
});
