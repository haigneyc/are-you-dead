-- Update cron jobs to use X-Cron-Secret header instead of Authorization
-- This allows Supabase JWT auth to work alongside our custom cron authentication

-- First, unschedule the old jobs
SELECT cron.unschedule('check-missed-checkins');
SELECT cron.unschedule('schedule-reminders');

-- Re-create with updated headers (Authorization for Supabase JWT, X-Cron-Secret for our auth)
SELECT cron.schedule(
  'check-missed-checkins',
  '*/5 * * * *',
  $$SELECT net.http_post(
    url := 'https://gpfiigrthuvlnvsnhifk.supabase.co/functions/v1/check-missed-checkins',
    headers := '{"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdwZmlpZ3J0aHV2bG52c25oaWZrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2ODI0MTQxMiwiZXhwIjoyMDgzODE3NDEyfQ.HZ2XwumfGU6dOWDR0A2sipFaYNiHZRKj_-ILYvH_v3I", "X-Cron-Secret": "BTWk3oRY4qtV1XuUuNCQXSnh0Yy0HiISg1+MaVkXN/I=", "Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  );$$
);

SELECT cron.schedule(
  'schedule-reminders',
  '0 * * * *',
  $$SELECT net.http_post(
    url := 'https://gpfiigrthuvlnvsnhifk.supabase.co/functions/v1/schedule-reminders',
    headers := '{"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdwZmlpZ3J0aHV2bG52c25oaWZrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2ODI0MTQxMiwiZXhwIjoyMDgzODE3NDEyfQ.HZ2XwumfGU6dOWDR0A2sipFaYNiHZRKj_-ILYvH_v3I", "X-Cron-Secret": "BTWk3oRY4qtV1XuUuNCQXSnh0Yy0HiISg1+MaVkXN/I=", "Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  );$$
);
