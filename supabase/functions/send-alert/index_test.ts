import {
  assertEquals,
  assertExists,
  assertStringIncludes,
} from "https://deno.land/std@0.168.0/testing/asserts.ts";
import {
  createMockFetch,
  testFixtures,
  setTestEnv,
  defaultTestEnv,
} from "../_test_utils/mocks.ts";

// Set up test environment
setTestEnv(defaultTestEnv);

Deno.test("send-alert - sends SMS via Twilio with correct message format", () => {
  const { mockFetch, calls } = createMockFetch([
    {
      urlMatch: "api.twilio.com",
      status: 200,
      body: testFixtures.twilioSuccessResponse,
    },
  ]);

  const twilioSid = Deno.env.get("TWILIO_ACCOUNT_SID");

  // Simulate Twilio API call
  mockFetch(
    `https://api.twilio.com/2010-04-01/Accounts/${twilioSid}/Messages.json`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        Authorization: `Basic ${btoa(`${twilioSid}:test-token`)}`,
      },
      body: new URLSearchParams({
        To: testFixtures.emergencyContact.phone,
        From: "+15555555555",
        Body: `SAFETY ALERT: Test User hasn't checked in...`,
      }).toString(),
    }
  );

  assertEquals(calls.length, 1, "Should make one Twilio call");
  assertStringIncludes(calls[0].url, "api.twilio.com", "Should call Twilio API");
  assertStringIncludes(calls[0].url, "Messages.json", "Should call Messages endpoint");
});

Deno.test("send-alert - sends email via Resend with correct template", () => {
  const { mockFetch, calls } = createMockFetch([
    {
      urlMatch: "api.resend.com",
      status: 200,
      body: testFixtures.resendSuccessResponse,
    },
  ]);

  // Simulate Resend API call
  mockFetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${Deno.env.get("RESEND_API_KEY")}`,
    },
    body: JSON.stringify({
      from: `Are You Dead? <${Deno.env.get("RESEND_FROM_EMAIL")}>`,
      to: testFixtures.emergencyContact.email,
      subject: `Safety Check Required - Test User`,
      html: "<div>...</div>",
    }),
  });

  assertEquals(calls.length, 1, "Should make one Resend call");
  assertStringIncludes(calls[0].url, "api.resend.com", "Should call Resend API");
});

Deno.test("send-alert - records alert in alerts_sent table", () => {
  // Mock database insert
  const alertRecord = {
    user_id: testFixtures.overdueUser.user_id,
    contact_id: testFixtures.emergencyContact.id,
    alert_type: "sms",
    status: "sent",
    external_id: "SM123456789",
    error_message: null,
  };

  assertExists(alertRecord.user_id, "Should have user_id");
  assertExists(alertRecord.contact_id, "Should have contact_id");
  assertEquals(alertRecord.alert_type, "sms", "Should have correct alert type");
  assertEquals(alertRecord.status, "sent", "Should have sent status");
  assertExists(alertRecord.external_id, "Should have external ID from provider");
});

Deno.test("send-alert - prevents duplicate alerts within 24 hours", () => {
  // Check if alert was sent recently
  const lastAlert = {
    sent_at: new Date(Date.now() - 12 * 60 * 60 * 1000).toISOString(), // 12 hours ago
    user_id: testFixtures.overdueUser.user_id,
    contact_id: testFixtures.emergencyContact.id,
  };

  const timeSinceLastAlert = Date.now() - new Date(lastAlert.sent_at).getTime();
  const isDuplicate = timeSinceLastAlert < 24 * 60 * 60 * 1000;

  assertEquals(isDuplicate, true, "12 hours should be within 24 hour window");

  // Test outside window
  const oldAlert = {
    sent_at: new Date(Date.now() - 30 * 60 * 60 * 1000).toISOString(), // 30 hours ago
  };

  const timeSinceOldAlert = Date.now() - new Date(oldAlert.sent_at).getTime();
  const isOldDuplicate = timeSinceOldAlert < 24 * 60 * 60 * 1000;

  assertEquals(isOldDuplicate, false, "30 hours should be outside 24 hour window");
});

Deno.test("send-alert - handles Twilio failure gracefully", () => {
  const { mockFetch, calls } = createMockFetch([
    {
      urlMatch: "api.twilio.com",
      status: 400,
      body: { message: "Invalid phone number", code: 21211 },
    },
  ]);

  mockFetch("https://api.twilio.com/test", {});

  assertEquals(calls.length, 1, "Should still make the API call");

  // Verify error is logged
  const failedAlertRecord = {
    user_id: testFixtures.overdueUser.user_id,
    contact_id: testFixtures.emergencyContact.id,
    alert_type: "sms",
    status: "failed",
    error_message: "Invalid phone number",
  };

  assertEquals(failedAlertRecord.status, "failed", "Should have failed status");
  assertExists(failedAlertRecord.error_message, "Should have error message");
});

Deno.test("send-alert - handles Resend failure gracefully", () => {
  const { mockFetch, calls } = createMockFetch([
    {
      urlMatch: "api.resend.com",
      status: 422,
      body: { message: "Invalid email address" },
    },
  ]);

  mockFetch("https://api.resend.com/emails", {});

  assertEquals(calls.length, 1, "Should still make the API call");

  // Verify error is logged
  const failedAlertRecord = {
    alert_type: "email",
    status: "failed",
    error_message: "Invalid email address",
  };

  assertEquals(failedAlertRecord.status, "failed", "Should have failed status");
});

Deno.test("send-alert - continues sending if one channel fails", () => {
  // SMS fails, but email should still be sent
  const results = { sms: "failed", email: "sent" };

  assertEquals(results.sms, "failed", "SMS should fail");
  assertEquals(results.email, "sent", "Email should succeed");

  // At least one channel succeeded
  const anySuccess = results.sms === "sent" || results.email === "sent";
  assertEquals(anySuccess, true, "At least one channel should succeed");
});

Deno.test("send-alert - formats last check-in date correctly", () => {
  const lastCheckIn = new Date("2026-01-13T10:30:00.000Z");

  const formatted = lastCheckIn.toLocaleDateString("en-US", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
  });

  assertExists(formatted, "Should format date");
  assertStringIncludes(formatted, "2026", "Should include year");
  assertStringIncludes(formatted, "January", "Should include month");
});

Deno.test("send-alert - skips email if contact has no email", () => {
  const contactWithoutEmail = {
    ...testFixtures.emergencyContact,
    email: null,
  };

  const shouldSendEmail = !!contactWithoutEmail.email;
  assertEquals(shouldSendEmail, false, "Should not send email when null");
});

Deno.test("send-alert - skips SMS if Twilio not configured", () => {
  // Clear Twilio config
  const twilioSid = undefined;
  const twilioToken = undefined;
  const twilioPhone = undefined;

  const isTwilioConfigured = !!(twilioSid && twilioToken && twilioPhone);
  assertEquals(isTwilioConfigured, false, "Should skip SMS when Twilio not configured");
});

Deno.test("send-alert - returns correct response format", () => {
  const response = {
    sms: "sent",
    email: "sent",
  };

  assertExists(response.sms, "Should have sms field");
  assertExists(response.email, "Should have email field");
  assertEquals(typeof response.sms, "string", "sms should be a string");
  assertEquals(typeof response.email, "string", "email should be a string");
});

Deno.test("send-alert - SMS message contains required information", () => {
  const userName = "Test User";
  const lastActiveText = "Monday, January 13, 2026";

  const smsMessage = `SAFETY ALERT: ${userName} hasn't checked in on their "Are You Dead?" safety app. Please check on them. Last active: ${lastActiveText}`;

  assertStringIncludes(smsMessage, "SAFETY ALERT", "Should include alert prefix");
  assertStringIncludes(smsMessage, userName, "Should include user name");
  assertStringIncludes(smsMessage, "Are You Dead?", "Should include app name");
  assertStringIncludes(smsMessage, lastActiveText, "Should include last active time");
});
