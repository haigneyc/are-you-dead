// Test utilities and mocks for Edge Function testing

/**
 * Mock Supabase client for testing
 */
export function createMockSupabaseClient(config: MockSupabaseConfig = {}) {
  const {
    rpcResults = {},
    selectResults = {},
    insertResults = {},
  } = config;

  return {
    rpc: (name: string, _params?: Record<string, unknown>) => ({
      data: rpcResults[name] ?? [],
      error: null,
    }),
    from: (table: string) => ({
      select: (_columns?: string) => ({
        eq: (_column: string, _value: unknown) => ({
          order: (_column: string, _options?: { ascending: boolean }) => ({
            data: selectResults[table] ?? [],
            error: null,
          }),
          single: () => ({
            data: selectResults[table]?.[0] ?? null,
            error: null,
          }),
          data: selectResults[table] ?? [],
          error: null,
        }),
        not: (_column: string, _operator: string, _value: unknown) => ({
          gte: (_column: string, _value: unknown) => ({
            lt: (_column: string, _value: unknown) => ({
              data: selectResults[table] ?? [],
              error: null,
            }),
          }),
        }),
      }),
      insert: (_data: Record<string, unknown>) => ({
        data: insertResults[table] ?? null,
        error: null,
      }),
    }),
  };
}

export interface MockSupabaseConfig {
  rpcResults?: Record<string, unknown[]>;
  selectResults?: Record<string, unknown[]>;
  insertResults?: Record<string, unknown>;
}

/**
 * Mock fetch for external APIs
 */
export function createMockFetch(responses: MockFetchResponse[]) {
  let callIndex = 0;
  const calls: MockFetchCall[] = [];

  const mockFetch = async (
    url: string | Request | URL,
    init?: RequestInit
  ): Promise<Response> => {
    const urlStr = url.toString();
    calls.push({ url: urlStr, init });

    // Find matching response
    const response = responses.find((r) => urlStr.includes(r.urlMatch));

    if (response) {
      if (response.error) {
        throw response.error;
      }
      return new Response(JSON.stringify(response.body ?? {}), {
        status: response.status ?? 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Default response
    callIndex++;
    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  };

  return { mockFetch, calls };
}

export interface MockFetchResponse {
  urlMatch: string;
  status?: number;
  body?: Record<string, unknown>;
  error?: Error;
}

export interface MockFetchCall {
  url: string;
  init?: RequestInit;
}

/**
 * Mock request for Edge Function testing
 */
export function createMockRequest(
  body: Record<string, unknown>,
  headers: Record<string, string> = {}
): Request {
  return new Request("http://localhost/test", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...headers,
    },
    body: JSON.stringify(body),
  });
}

/**
 * Test fixtures for common data
 */
export const testFixtures = {
  user: {
    id: "user-123",
    email: "test@example.com",
    display_name: "Test User",
    fcm_token: "test-fcm-token-123",
    check_in_interval_hours: 48,
    next_check_in_due: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    last_check_in_at: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
    notifications_enabled: true,
  },

  overdueUser: {
    user_id: "user-456",
    email: "overdue@example.com",
    display_name: "Overdue User",
    last_check_in_at: new Date(Date.now() - 72 * 60 * 60 * 1000).toISOString(),
    hours_overdue: 24,
  },

  emergencyContact: {
    id: "contact-123",
    user_id: "user-123",
    name: "Emergency Contact",
    phone: "+15551234567",
    email: "emergency@example.com",
    priority: 1,
    notify_on_add: false,
  },

  twilioSuccessResponse: {
    sid: "SM123456789",
    status: "queued",
    to: "+15551234567",
  },

  resendSuccessResponse: {
    id: "email-123456",
  },
};

/**
 * Helper to set test environment variables
 */
export function setTestEnv(env: Record<string, string>) {
  for (const [key, value] of Object.entries(env)) {
    Deno.env.set(key, value);
  }
}

/**
 * Helper to clear test environment variables
 */
export function clearTestEnv(keys: string[]) {
  for (const key of keys) {
    Deno.env.delete(key);
  }
}

/**
 * Default test environment variables
 */
export const defaultTestEnv: Record<string, string> = {
  SUPABASE_URL: "https://test.supabase.co",
  SUPABASE_SERVICE_ROLE_KEY: "test-service-key",
  TWILIO_ACCOUNT_SID: "test-twilio-sid",
  TWILIO_AUTH_TOKEN: "test-twilio-token",
  TWILIO_PHONE_NUMBER: "+15555555555",
  RESEND_API_KEY: "test-resend-key",
  RESEND_FROM_EMAIL: "test@example.com",
  CRON_SECRET: "test-cron-secret",
};
