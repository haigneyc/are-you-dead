import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const TWILIO_ACCOUNT_SID = Deno.env.get("TWILIO_ACCOUNT_SID")!;
const TWILIO_AUTH_TOKEN = Deno.env.get("TWILIO_AUTH_TOKEN")!;
const TWILIO_PHONE_NUMBER = Deno.env.get("TWILIO_PHONE_NUMBER")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;
const RESEND_FROM_EMAIL = Deno.env.get("RESEND_FROM_EMAIL") || "onboarding@resend.dev";

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
  const results: { sms: string | null; email: string | null } = {
    sms: null,
    email: null,
  };

  // Format last check-in date
  const lastCheckIn = body.last_check_in ? new Date(body.last_check_in) : null;
  const lastActiveText = lastCheckIn
    ? lastCheckIn.toLocaleDateString("en-US", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
        hour: "numeric",
        minute: "2-digit",
      })
    : "Unknown";

  const smsMessage = `SAFETY ALERT: ${body.user_name} hasn't checked in on their "Are You Dead?" safety app. Please check on them. Last active: ${lastActiveText}`;

  // Send SMS via Twilio
  if (TWILIO_ACCOUNT_SID && TWILIO_AUTH_TOKEN && TWILIO_PHONE_NUMBER) {
    try {
      const twilioResponse = await fetch(
        `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            Authorization: `Basic ${btoa(`${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}`)}`,
          },
          body: new URLSearchParams({
            To: body.contact_phone,
            From: TWILIO_PHONE_NUMBER,
            Body: smsMessage,
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
        external_id: twilioData.sid || null,
        error_message: twilioResponse.ok ? null : twilioData.message || "Unknown error",
      });

      results.sms = twilioResponse.ok ? "sent" : "failed";
      console.log(`SMS ${results.sms} to ${body.contact_phone}`);
    } catch (error) {
      console.error("SMS error:", error);
      await supabase.from("alerts_sent").insert({
        user_id: body.user_id,
        contact_id: body.contact_id,
        alert_type: "sms",
        status: "failed",
        error_message: String(error),
      });
      results.sms = "error";
    }
  } else {
    console.warn("Twilio not configured, skipping SMS");
  }

  // Send email via Resend (if email provided)
  if (body.contact_email && RESEND_API_KEY) {
    try {
      const emailResponse = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${RESEND_API_KEY}`,
        },
        body: JSON.stringify({
          from: `Are You Dead? <${RESEND_FROM_EMAIL}>`,
          to: body.contact_email,
          subject: `Safety Check Required - ${body.user_name}`,
          html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
              <h2 style="color: #dc2626;">Safety Check Required</h2>
              <p style="font-size: 16px; line-height: 1.6;">
                <strong>${body.user_name}</strong> hasn't checked in on their safety app
                "Are You Dead?" and may need assistance.
              </p>
              <p style="font-size: 16px; line-height: 1.6;">
                <strong>Last active:</strong> ${lastActiveText}
              </p>
              <p style="font-size: 16px; line-height: 1.6;">
                Please try to contact ${body.user_name} directly. If you cannot reach them,
                consider requesting a wellness check from local authorities.
              </p>
              <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 24px 0;">
              <p style="color: #6b7280; font-size: 12px;">
                This alert was sent by the "Are You Dead?" safety app.
                ${body.user_name} added you as an emergency contact.
              </p>
            </div>
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
        external_id: emailData.id || null,
        error_message: emailResponse.ok ? null : emailData.message || "Unknown error",
      });

      results.email = emailResponse.ok ? "sent" : "failed";
      console.log(`Email ${results.email} to ${body.contact_email}`);
    } catch (error) {
      console.error("Email error:", error);
      await supabase.from("alerts_sent").insert({
        user_id: body.user_id,
        contact_id: body.contact_id,
        alert_type: "email",
        status: "failed",
        error_message: String(error),
      });
      results.email = "error";
    }
  }

  return new Response(JSON.stringify(results), {
    headers: { "Content-Type": "application/json" },
  });
});
