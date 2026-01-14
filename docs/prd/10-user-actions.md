# 10 - User Actions (Non-Code Work)

[← Back to PRD](../PRD.md) | [← Previous: Launch Checklist](09-launch-checklist.md)

---

## Overview

This document covers all the **human tasks** required to bring the app to life—everything that isn't writing code. These tasks can often be done in parallel with development.

**Total Estimated Cost**: $160 - $1,400
**Total Estimated Time**: 1-2 weeks (can overlap with dev)

---

## 1. Account Setup (Services)

### Developer Accounts

| Service | Action | Cost | Time | Priority |
|---------|--------|------|------|----------|
| **Apple Developer** | Enroll at developer.apple.com | $99/year | 1-2 days (approval) | Required |
| **Google Play Console** | Register at play.google.com/console | $25 one-time | 1 day (approval) | Required |

**Apple Developer Steps**:
1. Go to https://developer.apple.com/programs/enroll/
2. Sign in with Apple ID (or create one)
3. Agree to Apple Developer Agreement
4. Pay $99 annual fee
5. Wait for approval (usually 24-48 hours)
6. Accept additional agreements in App Store Connect

**Google Play Console Steps**:
1. Go to https://play.google.com/console/signup
2. Sign in with Google account
3. Accept Developer Distribution Agreement
4. Pay $25 registration fee
5. Complete account details and verification
6. Set up payments profile (for receiving revenue)

---

### Backend Services

| Service | Action | Cost | Time | Priority |
|---------|--------|------|------|----------|
| **Supabase** | Create project | Free - $25/mo | 30 min | Required |
| **Firebase** | Create project, enable FCM | Free | 30 min | Required |
| **Twilio** | Sign up, verify, buy number | ~$1/mo + $0.0075/SMS | 1 hour | Required |
| **Resend** | Sign up, verify domain | Free (3K emails/mo) | 30 min | Required |

**Supabase Setup**:
1. Go to https://supabase.com
2. Sign up with GitHub
3. Create new project (choose region closest to users)
4. Note down: Project URL, publishable key, secret key
5. Enable Edge Functions
6. Set up pg_cron extension (for scheduled jobs)

**Firebase Setup**:
1. Go to https://console.firebase.google.com
2. Create new project
3. Add iOS app (download GoogleService-Info.plist)
4. Add Android app (download google-services.json)
5. Enable Cloud Messaging
6. Generate FCM server key (for Supabase Edge Functions)

**Twilio Setup**:
1. Go to https://www.twilio.com/try-twilio
2. Sign up with email
3. Verify phone number
4. Complete account verification (may require ID)
5. Buy a phone number (~$1/month)
6. Note down: Account SID, Auth Token, Phone Number
7. Add credits ($20 minimum recommended for testing)

**Resend Setup**:
1. Go to https://resend.com
2. Sign up with email
3. Verify your sending domain (add DNS records)
4. Generate API key
5. Test sending an email

---

### Domain & Hosting

| Service | Action | Cost | Time |
|---------|--------|------|------|
| **Domain Registrar** | Purchase domain | $12-40/year | 15 min |
| **DNS** | Configure records | Included | 30 min |
| **Hosting** | Landing page | $0-19/year | 1 hour |

**Domain Options**:
- `areyoudead.site` - Modern, matches app name
- `areyoudead.com` - Traditional (if available)
- `areyoudeadapp.com` - Backup option

**Recommended Registrars**:
- Cloudflare Registrar (cheapest, good DNS)
- Namecheap
- Google Domains

**DNS Records Needed**:
```
Type    Name              Value
A       @                 [Landing page IP]
CNAME   www               [Landing page]
MX      @                 [Email provider]
TXT     @                 [SPF record for email]
TXT     resend._domainkey [DKIM for Resend]
```

---

## 2. Legal Documents

### Required Documents

| Document | Purpose | Options |
|----------|---------|---------|
| **Privacy Policy** | Required by app stores | Generator, Lawyer, Template |
| **Terms of Service** | Limit liability | Generator, Lawyer, Template |
| **Disclaimer** | Medical device clarification | Write yourself |

### Privacy Policy

**What it must include**:
- What data you collect (email, phone, contacts, check-in times)
- How data is used (check-ins, alerts)
- Third parties (Supabase, Twilio, Firebase, Resend)
- Data retention (90 days history, 1 year alerts)
- User rights (access, deletion, export)
- Contact information
- GDPR compliance (if targeting EU)
- CCPA compliance (California users)

**Options**:

| Option | Cost | Pros | Cons |
|--------|------|------|------|
| **Termly** | $10/mo | Easy, comprehensive, auto-updates | Subscription |
| **iubenda** | $9/mo | Good templates, GDPR/CCPA | Subscription |
| **Lawyer** | $500-1000 | Custom, legally solid | Expensive |
| **Template** | Free | Quick | Risky, may miss requirements |

**Recommendation**: Use Termly or iubenda for MVP. Consider lawyer if app grows.

### Terms of Service

**Key clauses**:
- Service description and limitations
- User responsibilities (accurate info, not misuse)
- **Liability limitation** (critical for safety app):
  - "This app is not a medical device"
  - "Not a substitute for emergency services (911)"
  - "Alerts depend on network connectivity"
  - "We are not liable for missed alerts"
- Account termination conditions
- Dispute resolution (arbitration clause)
- Modification rights

### Disclaimer (Add to App)

```
IMPORTANT: "Are You Dead?" is not a medical device or emergency
service. It does not replace 911 or emergency responders. Alert
delivery depends on network connectivity and third-party services.
We cannot guarantee alerts will be delivered. For medical emergencies,
always call emergency services directly.
```

---

## 3. Design Assets

### App Icon

| Requirement | Specification |
|-------------|---------------|
| iOS | 1024×1024px PNG, no alpha/transparency |
| Android | 512×512px PNG |
| Format | Square, no rounded corners (system adds them) |

**Design Options**:

| Option | Cost | Time | Quality |
|--------|------|------|---------|
| Design yourself (Figma) | Free | 2-4 hours | Varies |
| Fiverr | $20-100 | 2-5 days | Good |
| 99designs | $300+ | 1 week | Professional |
| Hire designer | $200-500 | 3-7 days | Professional |
| AI tools (Midjourney) | $10/mo | 1-2 hours | Varies |

**Icon Concepts**:
- Skull with heart eyes (edgy but friendly)
- Heartbeat line that flatlines then pulses
- Simple checkmark in circle (clean, universal)
- Stylized "?" mark
- Person silhouette with pulse line

### Screenshots

| Platform | Sizes Required |
|----------|----------------|
| iOS 6.7" | 1290×2796px |
| iOS 6.5" | 1284×2778px |
| iOS 5.5" | 1242×2208px |
| Android Phone | Min 320px, max 3840px |
| Android Tablet | Optional |

**Screenshot Content** (5-8 images):
1. Main check-in screen with big button
2. Adding emergency contact
3. Settings/interval selection
4. Push notification example
5. Contact list view
6. Onboarding/value prop

**Tools**:
- **Screenshots Framer** - Device mockups with backgrounds
- **Figma** - Full design control
- **Canva** - Quick and easy templates
- **LaunchMatic** - Automated screenshot generation

### Feature Graphic (Android)

- Size: 1024×500px
- Used at top of Play Store listing
- Should communicate value prop visually

### Promotional Images

| Asset | Size | Use |
|-------|------|-----|
| Social share | 1200×630px | Open Graph/Twitter cards |
| Twitter header | 1500×500px | @areyoudeadapp |
| Instagram post | 1080×1080px | Launch announcement |

---

## 4. Content Writing

### App Store Description

**Character Limits**:
- iOS: 4,000 characters
- Android: 4,000 characters
- Short description (Android): 80 characters

**Structure**:
```
[Hook - 1 sentence]
[Problem - 2 sentences]
[Solution - 2 sentences]

HOW IT WORKS:
• [Bullet 1]
• [Bullet 2]
• [Bullet 3]

PERFECT FOR:
• [Audience 1]
• [Audience 2]
• [Audience 3]

FEATURES:
• [Feature list]

[Social proof if available]

[Pricing - one-time $1.99]

[Call to action]
```

### Keywords (iOS)

**Limit**: 100 characters, comma-separated

**Research Process**:
1. Brainstorm relevant terms
2. Check competition in App Store
3. Use App Annie or Sensor Tower for keyword research
4. Prioritize low-competition, high-relevance

**Suggested Keywords**:
```
safety,check-in,living alone,emergency contact,wellness,solo living,elderly,student safety,dead man switch
```

### FAQ Content

**Questions to answer**:
1. How does the app work?
2. What happens if I miss a check-in?
3. How do I add emergency contacts?
4. Can I change my check-in interval?
5. What information is shared with contacts?
6. Is my data secure?
7. What if I'm traveling/on vacation?
8. How do I delete my account?
9. Why did my contact receive an alert?
10. Does this replace calling 911?

### Support Response Templates

**Common scenarios**:
- False alert sent (apologize, explain snooze feature)
- Can't receive notifications (troubleshooting steps)
- Contact didn't receive alert (check phone/email, spam folders)
- Refund request (direct to app store)
- Feature request (thank and log)

---

## 5. Marketing Prep

### Social Media Accounts

| Platform | Handle | Priority |
|----------|--------|----------|
| Twitter/X | @areyoudeadapp | High |
| Instagram | @areyoudeadapp | Medium |
| TikTok | @areyoudeadapp | Medium (for viral potential) |
| Facebook | /areyoudeadapp | Low |

**Bio Template**:
```
Are You Dead? 💀
Safety check-in app for people living alone.
Check in or your emergency contacts are alerted.
iOS & Android | $1.99 one-time
[Link to website]
```

### Press Kit

**Contents**:
- App icon (high-res PNG)
- Screenshots (all sizes)
- Logo variations (light/dark background)
- One-paragraph description
- Founder bio/story (optional)
- Key statistics (if available post-launch)
- Contact email for press

**Host at**: areyoudead.site/press or Dropbox/Google Drive link

### Launch Announcement

**Prepare in advance**:
- Tweet thread (5-7 tweets telling the story)
- Instagram carousel
- Reddit post (r/apps, r/android, r/iphone, relevant communities)
- Product Hunt listing (optional, good for visibility)
- Hacker News "Show HN" post

### Outreach List

**Who to contact**:
- Tech bloggers covering app reviews
- Solo living / minimalist lifestyle influencers
- Mental health advocates
- Elderly care / aging-in-place communities
- Student safety organizations

---

## 6. Testing Infrastructure

### Test Accounts

| Type | Purpose | Setup |
|------|---------|-------|
| Twilio test number | SMS testing without cost | Use Twilio test credentials |
| Test email | Email delivery testing | Create test@areyoudead.site |
| Demo account | App Store review | Create with known credentials |

### Beta Testers

**Recruitment**:
- Friends and family (5-10 people)
- Twitter followers (call for beta testers)
- Reddit communities (offer free access)
- BetaList.com listing

**Target**: 20-50 beta testers before launch

**Feedback Collection**:
- In-app feedback button (link to form)
- Google Form or Typeform
- TestFlight feedback (iOS)
- Discord/Slack channel for testers

---

## 7. Support Setup

### Support Email

- Configure support@areyoudead.site
- Set up email forwarding to personal inbox (for MVP)
- Consider Help Scout or Intercom later

### Help Page

**Minimum content**:
- FAQ (see above)
- Contact form/email
- Privacy Policy link
- Terms of Service link

**Host at**: areyoudead.site/help or in-app WebView

### Response Expectations

- **Target response time**: 24-48 hours
- **Critical issues** (alerts not working): Same day
- **Refunds**: Direct to app store

---

## 8. Business Setup (Optional)

### Should You Form an LLC?

**Consider LLC if**:
- Expecting significant revenue
- Want liability protection
- Planning to raise investment
- Tax benefits make sense

**Skip for now if**:
- Just testing the idea
- Low revenue expected initially
- Comfortable with personal liability

### LLC Formation

| Service | Cost | Notes |
|---------|------|-------|
| LegalZoom | $79 + state fees | Easy, slow |
| Stripe Atlas | $500 | Includes bank account, fast |
| Firstbase | $399/year | Includes registered agent |
| DIY | $50-500 (state fees) | Cheapest, more work |

### Bank Account

- **For LLC**: Open business checking (Mercury, Chase)
- **For personal**: Use personal account, track separately

### Tax Considerations

- App store payments are taxable income
- Apple/Google withhold taxes for some countries
- Consider quarterly estimated taxes if revenue is significant
- Consult accountant if revenue exceeds $10K

---

## 9. Timeline Summary

### Pre-Development (Week 1)

| Day | Tasks |
|-----|-------|
| 1 | Register Apple Developer, Google Play Console |
| 1 | Purchase domain |
| 2 | Set up Supabase, Firebase |
| 2 | Set up Twilio, Resend |
| 3 | Draft Privacy Policy, Terms of Service |
| 3-5 | Design app icon |
| 5-7 | Set up social media accounts |

### During Development (Weeks 2-6)

| Task | When |
|------|------|
| Write app descriptions | Week 2 |
| Create screenshots | After UI complete |
| Recruit beta testers | Week 3 |
| Set up support email | Week 4 |
| Create FAQ | Week 5 |
| Prepare press kit | Week 5 |
| Write launch announcement | Week 6 |

### Pre-Launch (Week 7)

| Day | Tasks |
|-----|-------|
| 1 | Finalize all app store assets |
| 2 | Submit to TestFlight / Internal Testing |
| 3-5 | Beta testing with real users |
| 5 | Fix critical bugs from beta |
| 6 | Submit for App Store Review |
| 7 | Prepare launch day posts |

---

## 10. Cost Summary

### Required Costs

| Item | Cost |
|------|------|
| Apple Developer Account | $99/year |
| Google Play Console | $25 one-time |
| Domain | $15/year |
| **Subtotal** | **$139** |

### Optional Costs

| Item | Cost Range |
|------|------------|
| Privacy Policy generator | $0-120/year |
| App icon design | $0-200 |
| Landing page hosting | $0-19/year |
| Twilio credits (testing) | $20 |
| LLC formation | $0-500 |
| **Subtotal** | **$20 - $860** |

### Ongoing Costs (Post-Launch)

| Item | Monthly Cost |
|------|--------------|
| Twilio SMS | ~$0.0075/SMS |
| Supabase (if exceed free tier) | $25/mo |
| Resend (if exceed free tier) | $20/mo |
| Domain renewal | ~$1.25/mo |

**Estimated monthly cost with 1,000 active users**: $5-50/month

---

## Checklist

### Week 1: Accounts & Legal
- [ ] Apple Developer enrolled
- [ ] Google Play Console registered
- [ ] Domain purchased
- [x] Supabase project created
- [ ] Firebase project created
- [ ] Twilio account set up
- [ ] Resend account set up
- [ ] Privacy Policy drafted
- [ ] Terms of Service drafted

### Week 2-4: Assets & Content
- [ ] App icon designed
- [ ] App description written
- [ ] Keywords researched
- [ ] FAQ written
- [ ] Social media accounts created
- [ ] Support email configured

### Week 5-6: Pre-Launch
- [ ] Screenshots created
- [ ] Press kit assembled
- [ ] Beta testers recruited
- [ ] Launch announcement drafted
- [ ] All app store assets ready

### Launch Week
- [ ] Final review of all materials
- [ ] Submit for review
- [ ] Prepare launch day posts
- [ ] Notify beta testers
- [ ] Launch! 🚀

---

[← Back to PRD](../PRD.md)
