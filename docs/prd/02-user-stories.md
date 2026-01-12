# 02 - User Stories

[← Back to PRD](../PRD.md) | [← Previous: Product Overview](01-product-overview.md)

---

## User Personas

### Persona 1: Alex - The Remote Worker

| Attribute | Detail |
|-----------|--------|
| **Age** | 28 |
| **Location** | Denver, Colorado |
| **Living Situation** | Studio apartment, alone |
| **Occupation** | Software engineer (remote) |
| **Tech Comfort** | High |

**Background**: Alex moved to Denver for a job that went remote. Lives alone, works from home, and sometimes goes days without seeing anyone in person. Parents live in Ohio and worry constantly.

**Pain Points**:
- Parents text every day asking if they're OK (annoying)
- Occasionally thinks "what if I had a stroke and no one knew?"
- Doesn't want to install Life360 (too invasive)

**Goals**:
- Give parents peace of mind without constant check-ins
- Simple solution that doesn't require daily effort
- Something that "just works" in the background

**Quote**: *"I just want my mom to stop worrying without having to text her every single day."*

---

### Persona 2: Sarah - The Independent Elder

| Attribute | Detail |
|-----------|--------|
| **Age** | 72 |
| **Location** | Phoenix, Arizona |
| **Living Situation** | House, widowed |
| **Occupation** | Retired teacher |
| **Tech Comfort** | Medium (uses iPhone, Facebook) |

**Background**: Sarah's husband passed away 3 years ago. Her children live in other states and can't check on her daily. She's healthy but has high blood pressure and worries about falling.

**Pain Points**:
- Children worry about her but can't visit often
- Doesn't want to move to assisted living
- Medical alert pendants feel "old" and embarrassing

**Goals**:
- Stay independent in her own home
- Reassure children without feeling monitored
- Something dignified, not a "help I've fallen" device

**Quote**: *"I'm not ready for one of those necklaces. But I do think about what would happen if I fell."*

---

### Persona 3: Jordan - The Struggling Student

| Attribute | Detail |
|-----------|--------|
| **Age** | 22 |
| **Location** | Boston, Massachusetts |
| **Living Situation** | Apartment, alone |
| **Occupation** | Graduate student |
| **Tech Comfort** | High |

**Background**: Jordan moved across the country for grad school. Struggles with depression and anxiety. Has had periods of isolating for days. Parents are concerned but Jordan values independence.

**Pain Points**:
- Sometimes doesn't leave apartment for days
- Depression makes it hard to reach out
- Doesn't want to worry parents, but knows they worry anyway

**Goals**:
- A safety net for bad mental health days
- Something that doesn't require active effort when depressed
- Reassure family without daily calls

**Quote**: *"When I'm really low, I don't talk to anyone. This could be a quiet way to let someone know I'm still here."*

---

## User Stories

### Onboarding

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| US-01 | New user | Sign up with my email | I can create an account | Must |
| US-02 | New user | Add at least one emergency contact | Someone will be notified if I'm not OK | Must |
| US-03 | New user | Set my check-in interval | The app works on my schedule | Must |
| US-04 | New user | Understand how the app works | I trust the system | Must |
| US-05 | New user | Skip optional steps and finish later | I can start using the app quickly | Should |

### Check-In

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| US-10 | User | See a large, obvious check-in button | I can confirm I'm OK with one tap | Must |
| US-11 | User | See when my next check-in is due | I know my deadline | Must |
| US-12 | User | Check in with one tap | It takes minimal effort | Must |
| US-13 | User | See confirmation after checking in | I know it worked | Must |
| US-14 | User | Snooze my check-in by a few hours | I can delay if I'm busy | Should |

### Notifications

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| US-20 | User | Receive a reminder before my check-in expires | I don't forget | Must |
| US-21 | User | Receive multiple reminders (24h, 6h, 1h) | I have multiple chances | Must |
| US-22 | User | Know if my contacts were alerted | I can follow up if needed | Should |
| US-23 | User | Customize reminder times | It fits my schedule | Could |

### Emergency Contacts

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| US-30 | User | Add emergency contacts with phone and email | They can be reached multiple ways | Must |
| US-31 | User | Add multiple contacts | Multiple people can help | Must |
| US-32 | User | Edit or remove contacts | I can update my network | Must |
| US-33 | User | Set contact priority | I control who's notified first | Should |
| US-34 | User | Let contacts know they've been added | They expect potential alerts | Should |

### Emergency Alerts

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| US-40 | Emergency contact | Receive an SMS if the user misses check-in | I know to check on them | Must |
| US-41 | Emergency contact | Receive an email if the user misses check-in | I have backup notification | Must |
| US-42 | Emergency contact | Know when the user was last active | I have context | Should |
| US-43 | User | Include my location in alerts | Contacts know where to find me | Could |

### Settings & Account

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| US-50 | User | Change my check-in interval | I can adjust to my lifestyle | Must |
| US-51 | User | Manage notification preferences | I control what I receive | Should |
| US-52 | User | Update my profile (name, phone) | My info is current | Should |
| US-53 | User | Delete my account | I can leave the service | Must |
| US-54 | User | Export my data | I own my information | Could |

---

## User Journeys

### Journey 1: First-Time Setup (Alex)

```
1. Alex hears about app from a podcast
2. Downloads from App Store ($1.99)
3. Opens app → Welcome screen
4. Taps "Get Started"
5. Creates account with email
6. Adds mom as emergency contact (phone + email)
7. Sets interval to 2 days (default)
8. Sees main check-in screen
9. Taps "I'm OK" for first check-in
10. Sets up done → daily use begins
```

**Time to value**: ~3 minutes

---

### Journey 2: Regular Check-In (Sarah)

```
1. Sarah receives push notification: "Check in tomorrow"
2. Opens app from notification
3. Sees countdown timer: "18 hours remaining"
4. Taps big green "I'm OK" button
5. Sees confirmation: "Great! Next check-in in 2 days"
6. Closes app
```

**Time to complete**: ~10 seconds

---

### Journey 3: Missed Check-In Alert (Jordan)

```
1. Jordan's been depressed, ignoring phone
2. Push notifications go unnoticed (24h, 6h, 1h)
3. Check-in deadline passes
4. 1 hour grace period passes
5. System detects missed check-in
6. Jordan's mom receives SMS:
   "Jordan hasn't checked in on 'Are You Dead?' in 2 days.
   Please check on them. Last active: Jan 10, 2026."
7. Mom calls Jordan → Jordan is OK but grateful for check-in
8. Jordan opens app and checks in
```

**Alert delivery time**: ~5 seconds after grace period

---

### Journey 4: Contact Receives Alert

```
1. Mom (emergency contact) receives SMS
2. SMS contains: name, days since check-in, last active date
3. Mom calls Jordan directly
4. If no answer, mom has option to call local authorities
5. Mom can optionally click email link to download app
```

---

## Acceptance Criteria Examples

### US-12: One-Tap Check-In

**Given** I am logged in and viewing the main screen
**When** I tap the check-in button
**Then**:
- My check-in is recorded with current timestamp
- The countdown timer resets to my interval
- I see a success confirmation
- My `last_check_in_at` is updated in the database

### US-40: SMS Alert to Emergency Contact

**Given** a user has missed their check-in and grace period
**When** the system processes missed check-ins
**Then**:
- All emergency contacts receive an SMS
- SMS includes: user's name, days overdue, last active date
- Alert is logged in `alerts_sent` table
- No duplicate alerts within 24 hours

---

[Next: Features →](03-features.md)
