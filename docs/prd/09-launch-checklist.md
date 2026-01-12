# 09 - Launch Checklist

[← Back to PRD](../PRD.md) | [← Previous: Notification System](08-notification-system.md)

---

## Pre-Launch Requirements

### Legal & Compliance

- [ ] **Privacy Policy**
  - [ ] Data collection explained (email, phone, contacts)
  - [ ] Data usage explained (check-ins, alerts)
  - [ ] Third-party services disclosed (Supabase, Twilio, Resend, Firebase)
  - [ ] Data retention policy (90 days history, 1 year alerts)
  - [ ] User rights (access, deletion, export)
  - [ ] Contact information for privacy inquiries
  - [ ] GDPR compliance (if targeting EU)
  - [ ] CCPA compliance (California users)
  - [ ] Hosted at: `https://areyoudead.app/privacy`

- [ ] **Terms of Service**
  - [ ] Service description
  - [ ] User responsibilities
  - [ ] Liability limitations (not a medical device)
  - [ ] Account termination conditions
  - [ ] Dispute resolution
  - [ ] Hosted at: `https://areyoudead.app/terms`

- [ ] **App Disclaimer**
  - [ ] "This app is not a substitute for emergency services"
  - [ ] "Alerts depend on network connectivity"
  - [ ] "We are not responsible for missed alerts due to..."

---

### App Store Assets

#### iOS (App Store Connect)

| Asset | Specification | Status |
|-------|--------------|--------|
| App Icon | 1024×1024px PNG, no alpha | [ ] |
| Screenshots (6.7") | 1290×2796px, 3-10 images | [ ] |
| Screenshots (6.5") | 1284×2778px, 3-10 images | [ ] |
| Screenshots (5.5") | 1242×2208px, 3-10 images | [ ] |
| App Preview (optional) | 30s video, 1080p | [ ] |
| App Name | "Are You Dead?" (30 char max) | [ ] |
| Subtitle | "Safety for solo living" (30 char max) | [ ] |
| Description | See below (4000 char max) | [ ] |
| Keywords | See below (100 char max) | [ ] |
| Support URL | https://areyoudead.app/support | [ ] |
| Marketing URL | https://areyoudead.app | [ ] |
| Privacy Policy URL | https://areyoudead.app/privacy | [ ] |

#### Android (Google Play Console)

| Asset | Specification | Status |
|-------|--------------|--------|
| App Icon | 512×512px PNG | [ ] |
| Feature Graphic | 1024×500px | [ ] |
| Screenshots (phone) | 320-3840px, 2-8 images | [ ] |
| Screenshots (tablet) | 1080-7680px, optional | [ ] |
| Promo Video (optional) | YouTube URL | [ ] |
| Short Description | 80 char max | [ ] |
| Full Description | 4000 char max | [ ] |
| App Category | Lifestyle or Health & Fitness | [ ] |
| Content Rating | Complete questionnaire | [ ] |
| Privacy Policy URL | Required | [ ] |

---

### App Store Description

```
Are You Dead? - Safety Check-In for People Living Alone

Living alone? Give your loved ones peace of mind.

HOW IT WORKS:
• Set a check-in interval (1-7 days)
• Tap "I'm OK" before each deadline
• Miss a check-in? Your emergency contacts are alerted automatically

PERFECT FOR:
• Young professionals living alone in cities
• Students away from home
• Elderly parents living independently
• Anyone who wants a simple safety net

FEATURES:
• One-tap check-in - takes 2 seconds
• Multiple emergency contacts
• SMS and email alerts
• Customizable reminders (24h, 6h, 1h before)
• Simple, private, no tracking

WHY "ARE YOU DEAD?"
Inspired by the viral Chinese app "死了么" that became #1 in China. We brought it to English-speaking users with the same simple premise: if you don't check in, someone who cares will know.

NO SUBSCRIPTION. One-time purchase of $1.99.

Your safety shouldn't be complicated. Download now and set it up in 2 minutes.
```

### Keywords (iOS)

```
safety,check-in,living alone,emergency contact,wellness check,solo living,elderly,student safety,dead man switch,safety app
```

---

### Technical Pre-Launch

- [ ] **Backend**
  - [ ] Supabase project created (production)
  - [ ] Database migrations applied
  - [ ] RLS policies verified
  - [ ] Edge Functions deployed
  - [ ] Environment variables set
  - [ ] Cron jobs configured (5-min check, hourly reminders)

- [ ] **External Services**
  - [ ] Twilio account verified
  - [ ] Twilio phone number purchased
  - [ ] Resend domain verified
  - [ ] Firebase project configured
  - [ ] APNs certificates uploaded
  - [ ] FCM server key generated

- [ ] **App Build**
  - [ ] Flutter build passing (iOS + Android)
  - [ ] Release signing configured
  - [ ] ProGuard/R8 rules tested (Android)
  - [ ] Bitcode enabled (iOS)
  - [ ] App size optimized (<50MB)

---

## iOS Launch Process

### Apple Developer Program

- [ ] Enrolled in Apple Developer Program ($99/year)
- [ ] Certificates created (Development + Distribution)
- [ ] Provisioning profiles created
- [ ] App ID registered with Push Notifications capability

### App Store Connect Setup

1. [ ] Create new app in App Store Connect
2. [ ] Set pricing: Paid - Tier 1 ($0.99) or Tier 2 ($1.99)
3. [ ] Fill in app information
4. [ ] Upload screenshots and metadata
5. [ ] Set age rating (4+ likely, no objectionable content)
6. [ ] Configure app review information
   - [ ] Demo account credentials (if needed)
   - [ ] Contact information
   - [ ] Notes for reviewer

### TestFlight Beta

1. [ ] Upload build via Xcode or Transporter
2. [ ] Wait for processing (~15-30 min)
3. [ ] Submit for Beta App Review
4. [ ] Add internal testers (up to 100)
5. [ ] Add external testers (up to 10,000)
6. [ ] Collect feedback, iterate

### App Review Submission

1. [ ] Ensure all metadata complete
2. [ ] Select build for review
3. [ ] Answer export compliance questions
4. [ ] Submit for review
5. [ ] Wait for review (typically 24-48 hours)
6. [ ] Address any rejections
7. [ ] Approve for release

### Common Rejection Reasons (Avoid These)

| Reason | Prevention |
|--------|------------|
| Crashes/bugs | Extensive testing |
| Incomplete metadata | Fill all fields |
| Placeholder content | Remove lorem ipsum |
| Privacy issues | Complete privacy policy |
| Misleading description | Accurate feature list |

---

## Android Launch Process

### Google Play Developer Account

- [ ] Enrolled in Google Play Developer Program ($25 one-time)
- [ ] Developer profile completed
- [ ] Payment profile set up

### Google Play Console Setup

1. [ ] Create new app
2. [ ] Complete app content questionnaire
3. [ ] Set up pricing: Paid app ($1.99)
4. [ ] Add countries/regions for distribution
5. [ ] Upload app bundle (.aab)
6. [ ] Fill store listing

### Release Tracks

| Track | Purpose | Testers |
|-------|---------|---------|
| Internal | Dev team | Up to 100 |
| Closed | Beta testers | Up to 1000 per track |
| Open | Public beta | Unlimited |
| Production | Full release | Everyone |

### Launch Process

1. [ ] Upload signed AAB
2. [ ] Complete content rating questionnaire
3. [ ] Set up closed testing
4. [ ] Promote to production
5. [ ] Staged rollout (10% → 50% → 100%)

---

## Post-Launch

### Monitoring

- [ ] **Crash Reporting**
  - [ ] Firebase Crashlytics configured
  - [ ] Crash alerts set up
  - [ ] Review crashes daily (first week)

- [ ] **Analytics**
  - [ ] Firebase Analytics or similar
  - [ ] Track: installs, check-ins, alerts sent
  - [ ] Funnel: install → signup → contact added → first check-in

- [ ] **Backend Monitoring**
  - [ ] Supabase dashboard access
  - [ ] Database query performance
  - [ ] Edge Function logs

- [ ] **External Services**
  - [ ] Twilio delivery rates
  - [ ] Resend bounce rates
  - [ ] FCM delivery stats

### Customer Support

- [ ] Support email configured (support@areyoudead.app)
- [ ] FAQ page created
- [ ] App Store review responses plan
- [ ] Bug report process

### Reviews & Ratings

- [ ] Request reviews at appropriate moments (after successful check-in)
- [ ] Respond to all negative reviews
- [ ] Track sentiment over time

---

## Launch Day Checklist

### T-7 Days
- [ ] Final QA on production build
- [ ] App submitted for review
- [ ] Marketing materials ready
- [ ] Social media accounts created

### T-1 Day
- [ ] App approved and ready for sale
- [ ] Verify Supabase production is ready
- [ ] Verify Twilio/Resend credits
- [ ] Team on standby for issues

### Launch Day
- [ ] Release app to App Store
- [ ] Release app to Google Play
- [ ] Announce on social media
- [ ] Monitor for crashes/issues
- [ ] Respond to early reviews

### T+1 Day
- [ ] Review first-day metrics
- [ ] Address any critical bugs
- [ ] Thank early adopters
- [ ] Continue monitoring

---

## Success Metrics (First 30 Days)

| Metric | Target | Tracking |
|--------|--------|----------|
| Downloads | 1,000 | App Store Connect / Play Console |
| Revenue | $1,500+ | Store dashboards |
| App Rating | 4.0+ | Store listings |
| Day 1 Retention | 60%+ | Analytics |
| Check-in Rate | 85%+ | Supabase queries |
| Alert Accuracy | 100% | Supabase logs |
| Crash Rate | <1% | Crashlytics |
| Support Tickets | <10 | Email |

---

## Version 1.1 Planning

After successful launch, prioritize for v1.1:

| Feature | Priority | Effort |
|---------|----------|--------|
| Dark mode | High | Low |
| Check-in streak display | Medium | Low |
| Snooze button | Medium | Low |
| Contact notification on add | Medium | Medium |
| Widget (iOS/Android) | Medium | High |
| Localization (Spanish) | Low | Medium |

---

## Appendix: Useful Links

| Resource | URL |
|----------|-----|
| App Store Connect | https://appstoreconnect.apple.com |
| Google Play Console | https://play.google.com/console |
| Apple Developer | https://developer.apple.com |
| Supabase Dashboard | https://app.supabase.com |
| Twilio Console | https://console.twilio.com |
| Resend Dashboard | https://resend.com/dashboard |
| Firebase Console | https://console.firebase.google.com |

---

[← Back to PRD](../PRD.md)
