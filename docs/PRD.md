# Are You Dead? - Product Requirements Document

> A safety check-in app for people living alone

## Executive Summary

| Attribute | Value |
|-----------|-------|
| **Product** | Safety check-in mobile app |
| **Platform** | iOS + Android (Flutter) |
| **Business Model** | Paid app ($1.99) |
| **Target Launch** | Q2 2026 |

**Core Mechanic**: Users check in every X days (default: 2). If they miss a check-in, their designated emergency contacts are automatically alerted via SMS and email.

---

## Problem Statement

Solo living is rising globally:
- China projects 200 million single-person households by 2030
- Similar trends in US, Europe, and other developed markets
- Young professionals, students, and elderly increasingly live alone

**The fear**: Dying or having a medical emergency with no one to notice for days or weeks.

**Real user quote** (from Chinese social media): *"I sometimes wonder, if I died alone, who would collect my body?"*

---

## Solution

A dead-simple app that provides peace of mind:

1. **Set your interval** - Choose how often to check in (1-7 days)
2. **One-tap check-in** - Large button confirms you're OK
3. **Automatic alerts** - Miss a check-in? Contacts are notified immediately

No social features. No complexity. Just safety.

---

## Document Index

| # | Document | Description |
|---|----------|-------------|
| 1 | [Product Overview](prd/01-product-overview.md) | Vision, target audience, market analysis, success metrics |
| 2 | [User Stories](prd/02-user-stories.md) | User personas and detailed user stories |
| 3 | [Features](prd/03-features.md) | MVP features and future roadmap |
| 4 | [Technical Architecture](prd/04-technical-architecture.md) | Tech stack, system design, integrations |
| 5 | [Database Schema](prd/05-database-schema.md) | Data models, tables, RLS policies |
| 6 | [API Design](prd/06-api-design.md) | Supabase Edge Functions and client API |
| 7 | [UI/UX Specification](prd/07-ui-ux-spec.md) | Screens, navigation, design system |
| 8 | [Notification System](prd/08-notification-system.md) | Push notifications, SMS/email alerts |
| 9 | [Launch Checklist](prd/09-launch-checklist.md) | App store requirements, legal, beta testing |
| 10 | [User Actions](prd/10-user-actions.md) | Non-code work: accounts, legal, assets, marketing |

---

## Quick Reference

### Tech Stack
- **Mobile**: Flutter + Dart
- **Backend**: Supabase (Auth, Database, Edge Functions)
- **Push**: Firebase Cloud Messaging
- **SMS**: Twilio
- **Email**: Resend

### Key Screens
1. Check-In (main screen with big button)
2. Emergency Contacts (manage contacts)
3. Settings (interval, notifications, account)

### Alert Flow
```
User misses check-in
    ↓ (1 hour grace period)
Supabase Edge Function triggers
    ↓
SMS sent via Twilio
Email sent via Resend
    ↓
Alert logged in database
```

---

## Implementation Progress

### Phase 1: Foundation (Completed)
- [x] Flutter project scaffolding
- [x] Supabase client integration
- [x] Authentication (signup, login, logout, password reset)
- [x] GoRouter navigation with auth guards
- [x] Bottom navigation shell
- [x] User model (Freezed/JSON)
- [x] Material 3 theme with brand colors
- [x] Shared widgets (AppButton, AppTextField, LoadingOverlay)
- [x] Settings screen (profile display, logout)
- [x] Placeholder screens (check-in, contacts)

### Phase 2: Core Features (Not Started)
- [ ] Supabase project setup (user action)
- [ ] Database migrations
- [ ] Check-in button with animation
- [ ] Countdown timer
- [ ] Check-in history (backend)
- [ ] Emergency contacts CRUD
- [ ] Contact validation

### Phase 3: Notifications & Alerts (Not Started)
- [ ] Firebase project setup
- [ ] Push notification service
- [ ] Reminder notifications (24h, 6h, 1h)
- [ ] Twilio SMS integration
- [ ] Resend email integration
- [ ] Alert Edge Functions
- [ ] Cron job for missed check-ins

### Phase 4: Polish & Launch (Not Started)
- [ ] Onboarding flow
- [ ] App icons and screenshots
- [ ] App store listings
- [ ] Legal documents (privacy policy, terms)
- [ ] Beta testing
- [ ] Production deployment

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-12 | Initial PRD |
| 1.1 | 2026-01-12 | Added User Actions document (non-code work) |
| 1.2 | 2026-01-12 | Added implementation progress checklist |
