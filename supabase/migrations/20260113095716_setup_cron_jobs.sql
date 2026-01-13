-- Setup pg_cron jobs for Are You Dead? app
-- This migration sets up scheduled triggers for:
-- 1. check-missed-checkins: Every 5 minutes, finds overdue users and alerts contacts
-- 2. schedule-reminders: Every hour, sends push notification reminders

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- Grant permissions to postgres role
GRANT USAGE ON SCHEMA cron TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cron TO postgres;

-- Check for missed check-ins every 5 minutes
-- Finds users who missed their deadline + grace period and alerts their emergency contacts
SELECT cron.schedule(
  'check-missed-checkins',
  '*/5 * * * *',
  $$SELECT net.http_post(
    url := 'https://gpfiigrthuvlnvsnhifk.supabase.co/functions/v1/check-missed-checkins',
    headers := '{"Authorization": "Bearer BTWk3oRY4qtV1XuUuNCQXSnh0Yy0HiISg1+MaVkXN/I=", "Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  );$$
);

-- Send reminders every hour (at minute 0)
-- Sends push notifications to users approaching their check-in deadline
SELECT cron.schedule(
  'schedule-reminders',
  '0 * * * *',
  $$SELECT net.http_post(
    url := 'https://gpfiigrthuvlnvsnhifk.supabase.co/functions/v1/schedule-reminders',
    headers := '{"Authorization": "Bearer BTWk3oRY4qtV1XuUuNCQXSnh0Yy0HiISg1+MaVkXN/I=", "Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  );$$
);
