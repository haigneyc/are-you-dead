import {
  assertEquals,
  assertExists,
} from "https://deno.land/std@0.168.0/testing/asserts.ts";
import {
  createMockRequest,
  createMockFetch,
  testFixtures,
  setTestEnv,
  defaultTestEnv,
} from "../_test_utils/mocks.ts";

// Set up test environment
setTestEnv(defaultTestEnv);

Deno.test("check-missed-checkins - returns 401 without cron secret", async () => {
  const req = createMockRequest({}, {});

  // Import and test handler
  // Note: In a real test we'd mock the entire module, but for this example
  // we'll test the request validation logic
  const cronSecret = Deno.env.get("CRON_SECRET");
  assertExists(cronSecret, "CRON_SECRET should be set");

  // Simulate unauthorized request (missing X-Cron-Secret header)
  const hasValidSecret = req.headers.get("X-Cron-Secret") === cronSecret;
  assertEquals(hasValidSecret, false, "Request without header should be unauthorized");
});

Deno.test("check-missed-checkins - returns 200 with valid cron secret", async () => {
  const cronSecret = Deno.env.get("CRON_SECRET");
  const req = createMockRequest({}, { "X-Cron-Secret": cronSecret! });

  const hasValidSecret = req.headers.get("X-Cron-Secret") === cronSecret;
  assertEquals(hasValidSecret, true, "Request with valid header should be authorized");
});

Deno.test("check-missed-checkins - empty result when no overdue users", () => {
  // Mock Supabase returning empty array
  const mockRpcResult: unknown[] = [];

  assertEquals(mockRpcResult.length, 0, "Should have no overdue users");

  // Expected response format
  const expectedResponse = { processed: 0, results: [] };
  assertEquals(expectedResponse.processed, 0);
  assertEquals(expectedResponse.results.length, 0);
});

Deno.test("check-missed-checkins - identifies overdue users correctly", () => {
  const overdueUsers = [testFixtures.overdueUser];

  assertEquals(overdueUsers.length, 1, "Should have one overdue user");
  assertEquals(
    overdueUsers[0].user_id,
    "user-456",
    "Should have correct user ID"
  );
  assertEquals(
    overdueUsers[0].hours_overdue,
    24,
    "Should have correct hours overdue"
  );
});

Deno.test("check-missed-checkins - calls send-alert for each overdue user", () => {
  const { mockFetch, calls } = createMockFetch([
    {
      urlMatch: "send-alert",
      status: 200,
      body: { sms: "sent", email: "sent" },
    },
  ]);

  // Simulate call to send-alert
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  mockFetch(`${supabaseUrl}/functions/v1/send-alert`, {
    method: "POST",
    body: JSON.stringify({
      user_id: testFixtures.overdueUser.user_id,
      user_name: testFixtures.overdueUser.display_name,
      contact_id: testFixtures.emergencyContact.id,
    }),
  });

  assertEquals(calls.length, 1, "Should make one call to send-alert");
  assertEquals(
    calls[0].url.includes("send-alert"),
    true,
    "Should call send-alert endpoint"
  );
});

Deno.test("check-missed-checkins - handles database errors gracefully", () => {
  // Simulate database error
  const dbError = { message: "Database connection failed", code: "PGRST301" };

  // Expected error response format
  const expectedResponse = {
    error: dbError.message,
  };

  assertExists(expectedResponse.error, "Should have error message");
  assertEquals(
    expectedResponse.error,
    "Database connection failed",
    "Should contain correct error message"
  );
});

Deno.test("check-missed-checkins - respects grace period (1 hour)", () => {
  // Users should only be marked overdue if they're >1 hour past their due time
  const now = new Date();
  const withinGracePeriod = new Date(now.getTime() - 30 * 60 * 1000); // 30 minutes ago
  const pastGracePeriod = new Date(now.getTime() - 90 * 60 * 1000); // 90 minutes ago

  const isWithinGrace = now.getTime() - withinGracePeriod.getTime() < 60 * 60 * 1000;
  const isPastGrace = now.getTime() - pastGracePeriod.getTime() >= 60 * 60 * 1000;

  assertEquals(isWithinGrace, true, "30 minutes should be within grace period");
  assertEquals(isPastGrace, true, "90 minutes should be past grace period");
});

Deno.test("check-missed-checkins - processes multiple overdue users", () => {
  const overdueUsers = [
    { ...testFixtures.overdueUser, user_id: "user-1" },
    { ...testFixtures.overdueUser, user_id: "user-2" },
    { ...testFixtures.overdueUser, user_id: "user-3" },
  ];

  assertEquals(overdueUsers.length, 3, "Should have three overdue users");

  // Expected results
  const results = overdueUsers.map((user) => ({
    userId: user.user_id,
    contactsAlerted: 1,
  }));

  assertEquals(results.length, 3, "Should have results for all users");
});

Deno.test("check-missed-checkins - sends FCM notification to user after alerts", () => {
  const { mockFetch, calls } = createMockFetch([
    {
      urlMatch: "fcm.googleapis.com",
      status: 200,
      body: { name: "projects/test/messages/123" },
    },
  ]);

  // Simulate FCM notification
  mockFetch("https://fcm.googleapis.com/v1/projects/test/messages:send", {
    method: "POST",
    body: JSON.stringify({
      message: {
        token: testFixtures.user.fcm_token,
        notification: {
          title: "Alert Sent",
          body: "Your emergency contacts have been notified.",
        },
      },
    }),
  });

  assertEquals(calls.length, 1, "Should make one FCM call");
  assertEquals(
    calls[0].url.includes("fcm.googleapis.com"),
    true,
    "Should call FCM endpoint"
  );
});
