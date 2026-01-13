# 05 - Database Schema

[← Back to PRD](../PRD.md) | [← Previous: Technical Architecture](04-technical-architecture.md)

---

## Entity Relationship Diagram

```
┌─────────────────────┐       ┌─────────────────────┐
│       users         │       │  emergency_contacts │
├─────────────────────┤       ├─────────────────────┤
│ id (PK)             │──┐    │ id (PK)             │
│ email               │  │    │ user_id (FK)        │──┐
│ phone               │  │    │ name                │  │
│ display_name        │  │    │ phone               │  │
│ check_in_interval   │  │    │ email               │  │
│ last_check_in_at    │  │    │ priority            │  │
│ next_check_in_due   │  │    │ created_at          │  │
│ timezone            │  │    │ updated_at          │  │
│ fcm_token           │  │    └─────────────────────┘  │
│ created_at          │  │                             │
│ updated_at          │  │                             │
└─────────────────────┘  │                             │
           │             │                             │
           │             │    ┌─────────────────────┐  │
           │             └───►│  check_in_history   │  │
           │                  ├─────────────────────┤  │
           │                  │ id (PK)             │  │
           │                  │ user_id (FK)        │  │
           │                  │ checked_in_at       │  │
           │                  │ was_on_time         │  │
           │                  │ device_info         │  │
           │                  └─────────────────────┘  │
           │                                           │
           │                  ┌─────────────────────┐  │
           └─────────────────►│    alerts_sent      │◄─┘
                              ├─────────────────────┤
                              │ id (PK)             │
                              │ user_id (FK)        │
                              │ contact_id (FK)     │
                              │ sent_at             │
                              │ alert_type          │
                              │ status              │
                              │ error_message       │
                              └─────────────────────┘
```

---

## Table Definitions

### `users`

Stores user profiles and check-in state.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `auth.uid()` | Primary key, matches Supabase Auth |
| `email` | `text` | NO | - | User's email address |
| `phone` | `text` | YES | `null` | User's phone number |
| `display_name` | `text` | YES | `null` | Name shown to contacts |
| `check_in_interval_hours` | `integer` | NO | `48` | Hours between required check-ins |
| `last_check_in_at` | `timestamptz` | YES | `null` | Last successful check-in |
| `next_check_in_due` | `timestamptz` | YES | `null` | When next check-in expires |
| `timezone` | `text` | NO | `'UTC'` | User's timezone for notifications |
| `fcm_token` | `text` | YES | `null` | Firebase Cloud Messaging token |
| `location_enabled` | `boolean` | NO | `false` | Include location in alerts |
| `created_at` | `timestamptz` | NO | `now()` | Account creation time |
| `updated_at` | `timestamptz` | NO | `now()` | Last profile update |

**Indexes**:
- `users_pkey` on `id`
- `users_email_idx` on `email` (unique)
- `users_next_checkin_idx` on `next_check_in_due` (for cron queries)

---

### `emergency_contacts`

Stores emergency contacts for each user.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `user_id` | `uuid` | NO | - | Foreign key to users |
| `name` | `text` | NO | - | Contact's name |
| `phone` | `text` | NO | - | Contact's phone (E.164 format) |
| `email` | `text` | YES | `null` | Contact's email |
| `priority` | `integer` | NO | `1` | Alert order (1 = first) |
| `notify_on_add` | `boolean` | NO | `false` | Was contact notified when added |
| `created_at` | `timestamptz` | NO | `now()` | When contact was added |
| `updated_at` | `timestamptz` | NO | `now()` | Last update |

**Indexes**:
- `emergency_contacts_pkey` on `id`
- `emergency_contacts_user_idx` on `user_id`
- `emergency_contacts_priority_idx` on `(user_id, priority)`

**Constraints**:
- `fk_user` foreign key to `users(id)` on delete cascade
- `check_priority_positive` check `priority > 0`
- Maximum 5 contacts per user (enforced in application)

---

### `check_in_history`

Audit log of all check-ins.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `user_id` | `uuid` | NO | - | Foreign key to users |
| `checked_in_at` | `timestamptz` | NO | `now()` | When check-in occurred |
| `was_on_time` | `boolean` | NO | `true` | Was it before deadline |
| `device_info` | `jsonb` | YES | `null` | App version, OS, etc. |

**Indexes**:
- `check_in_history_pkey` on `id`
- `check_in_history_user_time_idx` on `(user_id, checked_in_at desc)`

**Constraints**:
- `fk_user` foreign key to `users(id)` on delete cascade

---

### `alerts_sent`

Audit log of all emergency alerts.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `user_id` | `uuid` | NO | - | User who missed check-in |
| `contact_id` | `uuid` | NO | - | Contact who was alerted |
| `sent_at` | `timestamptz` | NO | `now()` | When alert was sent |
| `alert_type` | `text` | NO | - | 'sms' or 'email' |
| `status` | `text` | NO | `'pending'` | 'pending', 'sent', 'failed' |
| `error_message` | `text` | YES | `null` | Error details if failed |
| `external_id` | `text` | YES | `null` | Twilio/Resend message ID |

**Indexes**:
- `alerts_sent_pkey` on `id`
- `alerts_sent_user_time_idx` on `(user_id, sent_at desc)`
- `alerts_sent_status_idx` on `status` (for retry logic)

**Constraints**:
- `fk_user` foreign key to `users(id)` on delete cascade
- `fk_contact` foreign key to `emergency_contacts(id)` on delete cascade
- `check_alert_type` check `alert_type in ('sms', 'email')`
- `check_status` check `status in ('pending', 'sent', 'failed')`

---

## SQL Migration

```sql
-- 001_initial_schema.sql

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    phone TEXT,
    display_name TEXT,
    check_in_interval_hours INTEGER NOT NULL DEFAULT 48,
    last_check_in_at TIMESTAMPTZ,
    next_check_in_due TIMESTAMPTZ,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    fcm_token TEXT,
    location_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX users_email_idx ON users(email);
CREATE INDEX users_next_checkin_idx ON users(next_check_in_due);

-- Emergency contacts table
CREATE TABLE emergency_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    priority INTEGER NOT NULL DEFAULT 1 CHECK (priority > 0),
    notify_on_add BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX emergency_contacts_user_idx ON emergency_contacts(user_id);
CREATE INDEX emergency_contacts_priority_idx ON emergency_contacts(user_id, priority);

-- Check-in history table
CREATE TABLE check_in_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    checked_in_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    was_on_time BOOLEAN NOT NULL DEFAULT TRUE,
    device_info JSONB
);

CREATE INDEX check_in_history_user_time_idx ON check_in_history(user_id, checked_in_at DESC);

-- Alerts sent table
CREATE TABLE alerts_sent (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES emergency_contacts(id) ON DELETE CASCADE,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    alert_type TEXT NOT NULL CHECK (alert_type IN ('sms', 'email')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed')),
    error_message TEXT,
    external_id TEXT
);

CREATE INDEX alerts_sent_user_time_idx ON alerts_sent(user_id, sent_at DESC);
CREATE INDEX alerts_sent_status_idx ON alerts_sent(status);

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger
CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER emergency_contacts_updated_at
    BEFORE UPDATE ON emergency_contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

## Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE check_in_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts_sent ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view own profile"
    ON users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Emergency contacts policies
CREATE POLICY "Users can view own contacts"
    ON emergency_contacts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own contacts"
    ON emergency_contacts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own contacts"
    ON emergency_contacts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own contacts"
    ON emergency_contacts FOR DELETE
    USING (auth.uid() = user_id);

-- Check-in history policies
CREATE POLICY "Users can view own check-ins"
    ON check_in_history FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own check-ins"
    ON check_in_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Alerts sent policies
CREATE POLICY "Users can view own alerts"
    ON alerts_sent FOR SELECT
    USING (auth.uid() = user_id);

-- Secret key bypass for Edge Functions
-- (Edge Functions use secret key which bypasses RLS)
```

---

## Database Functions

### `perform_check_in`

Atomic check-in operation.

```sql
CREATE OR REPLACE FUNCTION perform_check_in(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
    v_interval_hours INTEGER;
    v_next_due TIMESTAMPTZ;
    v_was_on_time BOOLEAN;
BEGIN
    -- Get user's interval
    SELECT check_in_interval_hours, next_check_in_due
    INTO v_interval_hours, v_next_due
    FROM users WHERE id = p_user_id;

    -- Determine if on time
    v_was_on_time := (v_next_due IS NULL OR NOW() <= v_next_due);

    -- Update user
    UPDATE users SET
        last_check_in_at = NOW(),
        next_check_in_due = NOW() + (v_interval_hours || ' hours')::INTERVAL
    WHERE id = p_user_id;

    -- Record history
    INSERT INTO check_in_history (user_id, was_on_time)
    VALUES (p_user_id, v_was_on_time);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### `get_overdue_users`

Find users who need alerts.

```sql
CREATE OR REPLACE FUNCTION get_overdue_users()
RETURNS TABLE (
    user_id UUID,
    email TEXT,
    display_name TEXT,
    last_check_in_at TIMESTAMPTZ,
    hours_overdue INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        u.email,
        u.display_name,
        u.last_check_in_at,
        EXTRACT(EPOCH FROM (NOW() - u.next_check_in_due))::INTEGER / 3600
    FROM users u
    WHERE u.next_check_in_due IS NOT NULL
      AND NOW() > u.next_check_in_due + INTERVAL '1 hour'  -- Grace period
      AND NOT EXISTS (
          -- No alert sent in last 24 hours
          SELECT 1 FROM alerts_sent a
          WHERE a.user_id = u.id
            AND a.sent_at > NOW() - INTERVAL '24 hours'
      );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Data Retention

| Table | Retention | Rationale |
|-------|-----------|-----------|
| `users` | Until deleted | Active accounts |
| `emergency_contacts` | Until deleted | Active contacts |
| `check_in_history` | 90 days | Audit trail |
| `alerts_sent` | 1 year | Legal/compliance |

```sql
-- Cleanup job (run weekly)
DELETE FROM check_in_history
WHERE checked_in_at < NOW() - INTERVAL '90 days';

DELETE FROM alerts_sent
WHERE sent_at < NOW() - INTERVAL '1 year';
```

---

[Next: API Design →](06-api-design.md)
