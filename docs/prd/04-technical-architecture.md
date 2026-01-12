# 04 - Technical Architecture

[← Back to PRD](../PRD.md) | [← Previous: Features](03-features.md)

---

## Tech Stack Overview

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Mobile** | Flutter 3.x + Dart | Cross-platform, single codebase, great DX |
| **State Management** | Riverpod | Type-safe, testable, recommended for Flutter |
| **Backend** | Supabase | Auth, Postgres, Edge Functions, Realtime |
| **Push Notifications** | Firebase Cloud Messaging | Industry standard, free tier generous |
| **SMS** | Twilio | Reliable, good API, reasonable pricing |
| **Email** | Resend | Modern API, good deliverability |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         MOBILE APP                               │
│                      (Flutter + Dart)                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   Screens   │  │  Providers  │  │  Services   │              │
│  │  (UI Layer) │  │  (Riverpod) │  │  (Data)     │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         SUPABASE                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │    Auth     │  │  Database   │  │   Edge      │              │
│  │             │  │  (Postgres) │  │  Functions  │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
│                                           │                      │
│  ┌─────────────┐                          │                      │
│  │  pg_cron    │──────────────────────────┘                      │
│  │  (Scheduler)│                                                 │
│  └─────────────┘                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │ Firebase │   │  Twilio  │   │  Resend  │
        │   FCM    │   │   SMS    │   │  Email   │
        └──────────┘   └──────────┘   └──────────┘
              │               │               │
              ▼               ▼               ▼
        ┌─────────────────────────────────────────┐
        │              END USERS                   │
        │  (App user + Emergency Contacts)         │
        └─────────────────────────────────────────┘
```

---

## Mobile App Architecture

### Project Structure

```
lib/
├── main.dart                     # Entry point
├── app.dart                      # MaterialApp, theme, routing
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart    # Intervals, limits
│   │   └── api_constants.dart    # URLs, keys
│   ├── theme/
│   │   ├── app_theme.dart        # Material 3 theme
│   │   └── app_colors.dart       # Color palette
│   └── utils/
│       ├── validators.dart       # Input validation
│       └── formatters.dart       # Date/phone formatting
│
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── widgets/
│   │       └── auth_form.dart
│   │
│   ├── check_in/
│   │   ├── screens/
│   │   │   └── check_in_screen.dart
│   │   ├── providers/
│   │   │   └── check_in_provider.dart
│   │   └── widgets/
│   │       ├── check_in_button.dart
│   │       └── countdown_timer.dart
│   │
│   ├── contacts/
│   │   ├── screens/
│   │   │   ├── contacts_screen.dart
│   │   │   └── add_contact_screen.dart
│   │   ├── providers/
│   │   │   └── contacts_provider.dart
│   │   └── widgets/
│   │       └── contact_card.dart
│   │
│   └── settings/
│       ├── screens/
│       │   └── settings_screen.dart
│       └── providers/
│           └── settings_provider.dart
│
├── models/
│   ├── user.dart
│   ├── emergency_contact.dart
│   └── check_in.dart
│
├── services/
│   ├── supabase_service.dart     # Supabase client wrapper
│   ├── notification_service.dart  # FCM handling
│   └── storage_service.dart       # Local persistence
│
└── widgets/
    ├── app_button.dart
    ├── app_text_field.dart
    └── loading_overlay.dart
```

### State Management (Riverpod)

```dart
// Example: Check-in provider
@riverpod
class CheckIn extends _$CheckIn {
  @override
  Future<CheckInState> build() async {
    final user = await ref.watch(currentUserProvider.future);
    return CheckInState(
      lastCheckIn: user.lastCheckInAt,
      nextDue: user.nextCheckInDue,
      interval: user.checkInIntervalHours,
    );
  }

  Future<void> checkIn() async {
    state = const AsyncLoading();
    try {
      await ref.read(supabaseServiceProvider).recordCheckIn();
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
```

---

## Backend Architecture (Supabase)

### Database

See [05-database-schema.md](05-database-schema.md) for full schema.

### Edge Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `check-missed-checkins` | Cron (every 5 min) | Find overdue users, trigger alerts |
| `send-alert` | HTTP (internal) | Send SMS + email to contacts |
| `schedule-reminders` | Cron (every hour) | Queue push notifications |

### Authentication

- **Provider**: Supabase Auth (email/password)
- **Session**: JWT tokens, auto-refresh
- **Security**: RLS policies on all tables

---

## External Integrations

### Firebase Cloud Messaging (FCM)

**Purpose**: Push notifications to user devices

**Setup**:
1. Create Firebase project
2. Add `google-services.json` (Android)
3. Add `GoogleService-Info.plist` (iOS)
4. Configure APNs for iOS

**Notification Types**:
| Type | Trigger | Content |
|------|---------|---------|
| Reminder | Cron job | "Check in within X hours" |
| Overdue | Missed check-in | "You missed your check-in" |
| Alert sent | After alert | "Your contacts have been notified" |

### Twilio (SMS)

**Purpose**: Send SMS alerts to emergency contacts

**Configuration**:
```typescript
// Edge Function environment variables
TWILIO_ACCOUNT_SID=xxx
TWILIO_AUTH_TOKEN=xxx
TWILIO_PHONE_NUMBER=+1234567890
```

**Cost Estimate**:
- ~$0.0075/SMS (US)
- Budget: $50/month for 6,600 SMS

### Resend (Email)

**Purpose**: Send email alerts to emergency contacts

**Configuration**:
```typescript
RESEND_API_KEY=xxx
RESEND_FROM_EMAIL=alerts@areyoudead.app
```

**Cost**: Free tier (3,000 emails/month)

---

## Security Considerations

### Data Protection

| Data | Protection |
|------|------------|
| Passwords | Hashed by Supabase Auth (bcrypt) |
| API keys | Environment variables, never in code |
| Contact info | Encrypted at rest (Supabase default) |
| User sessions | JWT with 1-hour expiry, refresh tokens |

### Row Level Security (RLS)

All tables have RLS enabled. Users can only access their own data.

```sql
-- Example policy
CREATE POLICY "Users can only read own data"
ON users FOR SELECT
USING (auth.uid() = id);
```

### API Security

- All endpoints require authentication
- Rate limiting on Supabase (built-in)
- Edge Functions use service role only for alerts

### Privacy

- No tracking/analytics beyond necessary
- No data sold to third parties
- GDPR-compliant data deletion
- Clear privacy policy required

---

## Scalability

### Current Limits (Free/Starter Tiers)

| Service | Limit | Sufficient For |
|---------|-------|----------------|
| Supabase | 500MB database | ~100K users |
| Supabase | 2GB bandwidth/month | ~50K active users |
| Firebase | 1M notifications/month | ~50K users |
| Twilio | Pay-per-use | Unlimited |
| Resend | 3K emails/month | ~1.5K active users |

### Scaling Path

1. **0-10K users**: Free tiers sufficient
2. **10K-100K users**: Supabase Pro ($25/month), Resend paid
3. **100K+ users**: Dedicated Supabase, consider SMS alternatives

---

## Development & Deployment

### Local Development

```bash
# Flutter app
flutter run

# Supabase local
supabase start
supabase functions serve
```

### CI/CD

- **Mobile**: GitHub Actions → Build → Deploy to TestFlight/Play Console
- **Backend**: Supabase CLI → Deploy Edge Functions

### Environments

| Environment | Purpose | Supabase Project |
|-------------|---------|------------------|
| Local | Development | Local Docker |
| Staging | Testing | Separate project |
| Production | Live app | Main project |

---

## Monitoring & Observability

### Metrics to Track

| Metric | Tool |
|--------|------|
| App crashes | Firebase Crashlytics |
| API errors | Supabase Dashboard |
| SMS delivery | Twilio Console |
| Email delivery | Resend Dashboard |

### Alerting

- Supabase database connection failures
- Edge Function errors
- High SMS failure rate (>5%)
- User-reported issues via App Store

---

[Next: Database Schema →](05-database-schema.md)
