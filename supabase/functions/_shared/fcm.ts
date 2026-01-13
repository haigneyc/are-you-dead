// FCM v1 API helper for sending push notifications
// Uses service account authentication (OAuth 2.0)

interface ServiceAccount {
  type: string;
  project_id: string;
  private_key_id: string;
  private_key: string;
  client_email: string;
  client_id: string;
  auth_uri: string;
  token_uri: string;
}

interface FCMMessage {
  token: string;
  notification: {
    title: string;
    body: string;
  };
  data?: Record<string, string>;
  android?: {
    priority?: "normal" | "high";
    notification?: {
      channel_id?: string;
    };
  };
  apns?: {
    payload?: {
      aps?: {
        sound?: string;
        badge?: number;
      };
    };
  };
}

// Cache for access token
let cachedToken: { token: string; expiry: number } | null = null;

/**
 * Get OAuth2 access token for FCM
 */
async function getAccessToken(serviceAccount: ServiceAccount): Promise<string> {
  // Check cache
  if (cachedToken && cachedToken.expiry > Date.now() + 60000) {
    return cachedToken.token;
  }

  const now = Math.floor(Date.now() / 1000);
  const expiry = now + 3600; // 1 hour

  // Create JWT header
  const header = {
    alg: "RS256",
    typ: "JWT",
  };

  // Create JWT payload
  const payload = {
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: serviceAccount.token_uri,
    iat: now,
    exp: expiry,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  };

  // Encode header and payload
  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const signatureInput = `${encodedHeader}.${encodedPayload}`;

  // Sign with private key
  const signature = await signRS256(signatureInput, serviceAccount.private_key);
  const jwt = `${signatureInput}.${signature}`;

  // Exchange JWT for access token
  const tokenResponse = await fetch(serviceAccount.token_uri, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!tokenResponse.ok) {
    const error = await tokenResponse.text();
    throw new Error(`Failed to get access token: ${error}`);
  }

  const tokenData = await tokenResponse.json();

  // Cache token
  cachedToken = {
    token: tokenData.access_token,
    expiry: Date.now() + tokenData.expires_in * 1000,
  };

  return tokenData.access_token;
}

/**
 * Base64 URL encode
 */
function base64UrlEncode(str: string): string {
  const base64 = btoa(str);
  return base64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "");
}

/**
 * Sign data with RS256 using the private key
 */
async function signRS256(data: string, privateKeyPem: string): Promise<string> {
  // Import the private key
  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(privateKeyPem),
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"]
  );

  // Sign the data
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    new TextEncoder().encode(data)
  );

  // Convert to base64url
  return arrayBufferToBase64Url(signature);
}

/**
 * Convert PEM to ArrayBuffer
 */
function pemToArrayBuffer(pem: string): ArrayBuffer {
  const base64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s/g, "");
  const binary = atob(base64);
  const buffer = new ArrayBuffer(binary.length);
  const view = new Uint8Array(buffer);
  for (let i = 0; i < binary.length; i++) {
    view[i] = binary.charCodeAt(i);
  }
  return buffer;
}

/**
 * Convert ArrayBuffer to base64url
 */
function arrayBufferToBase64Url(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = "";
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "");
}

/**
 * Send FCM notification using v1 API
 */
export async function sendFCMNotification(
  message: FCMMessage
): Promise<{ success: boolean; error?: string }> {
  const serviceAccountJson = Deno.env.get("FCM_SERVICE_ACCOUNT");

  if (!serviceAccountJson) {
    console.error("FCM_SERVICE_ACCOUNT not configured");
    return { success: false, error: "FCM not configured" };
  }

  let serviceAccount: ServiceAccount;
  try {
    serviceAccount = JSON.parse(serviceAccountJson);
  } catch (e) {
    console.error("Failed to parse FCM_SERVICE_ACCOUNT:", e);
    return { success: false, error: "Invalid service account" };
  }

  try {
    const accessToken = await getAccessToken(serviceAccount);

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: message.token,
            notification: message.notification,
            data: message.data,
            android: message.android,
            apns: message.apns,
          },
        }),
      }
    );

    if (!response.ok) {
      const error = await response.json();
      console.error("FCM error:", error);
      return { success: false, error: JSON.stringify(error) };
    }

    return { success: true };
  } catch (e) {
    console.error("FCM error:", e);
    return { success: false, error: String(e) };
  }
}
