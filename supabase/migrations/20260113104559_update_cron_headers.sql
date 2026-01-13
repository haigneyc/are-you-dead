-- Update cron jobs to use X-Cron-Secret header instead of Authorization
-- This allows Supabase JWT auth to work alongside our custom cron authentication
--
-- IMPORTANT: This migration contains placeholder values.
-- Apply manually via Supabase SQL Editor with your actual secrets.
-- See /secrets/README.md for instructions.

-- First, unschedule the old jobs
SELECT cron.unschedule('check-missed-checkins');
SELECT cron.unschedule('schedule-reminders');

-- Re-create with updated headers (Authorization for Supabase JWT, X-Cron-Secret for our auth)
-- Replace <SUPABASE_SERVICE_ROLE_KEY> and <CRON_SECRET> with actual values
SELECT cron.schedule(
  'check-missed-checkins',
  '*/5 * * * *',
  $$SELECT net.http_post(
    url := 'https://gpfiigrthuvlnvsnhifk.supabase.co/functions/v1/check-missed-checkins',
    headers := '{"Authorization": "Bearer <SUPABASE_SERVICE_ROLE_KEY>", "X-Cron-Secret": "<CRON_SECRET>", "Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  );$$
);

SELECT cron.schedule(
  'schedule-reminders',
  '0 * * * *',
  $$SELECT net.http_post(
    url := 'https://gpfiigrthuvlnvsnhifk.supabase.co/functions/v1/schedule-reminders',
    headers := '{"Authorization": "Bearer <SUPABASE_SERVICE_ROLE_KEY>", "X-Cron-Secret": "<CRON_SECRET>", "Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  );$$
);
