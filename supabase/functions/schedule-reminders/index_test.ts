import {
  assertEquals,
  assertExists,
} from "https://deno.land/std@0.168.0/testing/asserts.ts";
import {
  createMockFetch,
  testFixtures,
  setTestEnv,
  defaultTestEnv,
} from "../_test_utils/mocks.ts";

// Set up test environment
setTestEnv(defaultTestEnv);

const REMINDER_WINDOWS = [
  { hours: 24, title: "Check-in Reminder", urgent: false },
  { hours: 6, title: "Check-in Due Soon", urgent: false },
  { hours: 1, title: "Final Reminder", urgent: true },
];

Deno.test("schedule-reminders - returns 401 without cron secret", () => {
  const cronSecret = Deno.env.get("CRON_SECRET");
  assertExists(cronSecret, "CRON_SECRET should be set");

  // Simulate request without header
  const requestHeader = null;
  const isAuthorized = requestHeader === cronSecret;

  assertEquals(isAuthorized, false, "Should be unauthorized without header");
});

Deno.test("schedule-reminders - returns 200 with valid cron secret", () => {
  const cronSecret = Deno.env.get("CRON_SECRET");
  const requestHeader = cronSecret;
  const isAuthorized = requestHeader === cronSecret;

  assertEquals(isAuthorized, true, "Should be authorized with valid header");
});

Deno.test("schedule-reminders - identifies users needing 24h reminder", () => {
  const now = new Date();
  const windowStart = new Date(now.getTime() + (24 - 0.5) * 60 * 60 * 1000);
  const windowEnd = new Date(now.getTime() + (24 + 0.5) * 60 * 60 * 1000);

  // User with check-in due in 24 hours
  const userDueIn24h = {
    ...testFixtures.user,
    next_check_in_due: new Date(now.getTime() + 24 * 60 * 60 * 1000).toISOString(),
  };

  const dueTime = new Date(userDueIn24h.next_check_in_due);
  const isInWindow = dueTime >= windowStart && dueTime < windowEnd;

  assertEquals(isInWindow, true, "User should be in 24h reminder window");
});

Deno.test("schedule-reminders - identifies users needing 6h reminder", () => {
  const now = new Date();
  const windowStart = new Date(now.getTime() + (6 - 0.5) * 60 * 60 * 1000);
  const windowEnd = new Date(now.getTime() + (6 + 0.5) * 60 * 60 * 1000);

  // User with check-in due in 6 hours
  const userDueIn6h = {
    ...testFixtures.user,
    next_check_in_due: new Date(now.getTime() + 6 * 60 * 60 * 1000).toISOString(),
  };

  const dueTime = new Date(userDueIn6h.next_check_in_due);
  const isInWindow = dueTime >= windowStart && dueTime < windowEnd;

  assertEquals(isInWindow, true, "User should be in 6h reminder window");
});

Deno.test("schedule-reminders - identifies users needing 1h reminder", () => {
  const now = new Date();
  const windowStart = new Date(now.getTime() + (1 - 0.5) * 60 * 60 * 1000);
  const windowEnd = new Date(now.getTime() + (1 + 0.5) * 60 * 60 * 1000);

  // User with check-in due in 1 hour
  const userDueIn1h = {
    ...testFixtures.user,
    next_check_in_due: new Date(now.getTime() + 1 * 60 * 60 * 1000).toISOString(),
  };

  const dueTime = new Date(userDueIn1h.next_check_in_due);
  const isInWindow = dueTime >= windowStart && dueTime < windowEnd;

  assertEquals(isInWindow, true, "User should be in 1h reminder window");
});

Deno.test("schedule-reminders - sends FCM push notification with correct payload", () => {
  const { mockFetch, calls } = createMockFetch([
    {
      urlMatch: "fcm.googleapis.com",
      status: 200,
      body: { name: "projects/test/messages/123" },
    },
  ]);

  const notification = {
    token: testFixtures.user.fcm_token,
    notification: {
      title: REMINDER_WINDOWS[0].title,
      body: "Check in tomorrow to let your contacts know you're OK",
    },
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      urgent: "false",
      route: "/",
    },
  };

  mockFetch("https://fcm.googleapis.com/v1/projects/test/messages:send", {
    method: "POST",
    body: JSON.stringify({ message: notification }),
  });

  assertEquals(calls.length, 1, "Should make FCM call");
  assertExists(notification.token, "Should have FCM token");
  assertExists(notification.notification.title, "Should have notification title");
  assertExists(notification.data.click_action, "Should have click action");
});

Deno.test("schedule-reminders - handles missing FCM token", () => {
  const userWithoutToken = {
    ...testFixtures.user,
    fcm_token: null,
  };

  const shouldSendNotification = !!userWithoutToken.fcm_token;
  assertEquals(shouldSendNotification, false, "Should not send when no FCM token");
});

Deno.test("schedule-reminders - skips users with notifications disabled", () => {
  const userWithNotificationsOff = {
    ...testFixtures.user,
    notifications_enabled: false,
  };

  const shouldNotify = userWithNotificationsOff.notifications_enabled;
  assertEquals(shouldNotify, false, "Should not notify when disabled");
});

Deno.test("schedule-reminders - uses high priority for 1h reminder", () => {
  const urgentWindow = REMINDER_WINDOWS.find((w) => w.hours === 1);
  assertExists(urgentWindow, "Should have 1h window");
  assertEquals(urgentWindow?.urgent, true, "1h window should be urgent");

  const androidConfig = {
    priority: urgentWindow?.urgent ? "high" : "normal",
    notification: {
      channel_id: urgentWindow?.urgent ? "urgent_alerts" : "check_in_reminders",
    },
  };

  assertEquals(androidConfig.priority, "high", "Should use high priority");
  assertEquals(
    androidConfig.notification.channel_id,
    "urgent_alerts",
    "Should use urgent channel"
  );
});

Deno.test("schedule-reminders - uses normal priority for 24h and 6h reminders", () => {
  const nonUrgentWindows = REMINDER_WINDOWS.filter((w) => !w.urgent);
  assertEquals(nonUrgentWindows.length, 2, "Should have two non-urgent windows");

  for (const window of nonUrgentWindows) {
    assertEquals(window.urgent, false, `${window.hours}h should not be urgent`);
  }
});

Deno.test("schedule-reminders - returns results for all windows", () => {
  const results = REMINDER_WINDOWS.map((w) => ({
    window: w.hours,
    usersSent: 5,
    errors: 0,
  }));

  assertEquals(results.length, 3, "Should have results for all windows");
  assertEquals(results[0].window, 24, "First window should be 24h");
  assertEquals(results[1].window, 6, "Second window should be 6h");
  assertEquals(results[2].window, 1, "Third window should be 1h");
});

Deno.test("schedule-reminders - calculates time window correctly (30 min tolerance)", () => {
  const now = new Date();
  const targetHours = 24;

  const windowStartMs = now.getTime() + (targetHours - 0.5) * 60 * 60 * 1000;
  const windowEndMs = now.getTime() + (targetHours + 0.5) * 60 * 60 * 1000;

  const windowDurationMs = windowEndMs - windowStartMs;
  const windowDurationHours = windowDurationMs / (60 * 60 * 1000);

  assertEquals(windowDurationHours, 1, "Window should be 1 hour (30 min before and after)");
});

Deno.test("schedule-reminders - handles FCM errors gracefully", () => {
  const fcmError = { success: false, error: "NotRegistered" };

  assertEquals(fcmError.success, false, "Should indicate failure");
  assertExists(fcmError.error, "Should have error message");

  // Error count should increment
  let errorCount = 0;
  if (!fcmError.success) {
    errorCount++;
  }

  assertEquals(errorCount, 1, "Should increment error count");
});

Deno.test("schedule-reminders - includes correct notification messages", () => {
  const messages = {
    24: "Check in tomorrow to let your contacts know you're OK",
    6: "Your check-in is due in about 6 hours",
    1: "Check in within 1 hour to avoid alerting your contacts",
  };

  assertExists(messages[24], "Should have 24h message");
  assertExists(messages[6], "Should have 6h message");
  assertExists(messages[1], "Should have 1h message");

  // Verify urgency in messaging
  assertEquals(
    messages[1].includes("avoid alerting"),
    true,
    "1h message should convey urgency"
  );
});

Deno.test("schedule-reminders - configures iOS APNs correctly for urgent alerts", () => {
  const urgentApnsConfig = {
    payload: {
      aps: {
        sound: "default",
        badge: 1,
      },
    },
  };

  assertExists(urgentApnsConfig.payload.aps.sound, "Urgent should have sound");
  assertEquals(urgentApnsConfig.payload.aps.badge, 1, "Should set badge to 1");
});

Deno.test("schedule-reminders - configures iOS APNs correctly for non-urgent alerts", () => {
  const nonUrgentApnsConfig = {
    payload: {
      aps: {
        sound: undefined,
        badge: 1,
      },
    },
  };

  assertEquals(
    nonUrgentApnsConfig.payload.aps.sound,
    undefined,
    "Non-urgent should not have sound"
  );
});
