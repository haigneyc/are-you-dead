# Test PRD - Are You Dead?

> Testing architecture and implementation checklist

## Overview

**Testing Strategy:** Coverage-first approach with dependency injection for clean mocking.

| Layer | Framework | Purpose |
|-------|-----------|---------|
| Unit | flutter_test | Validators, models, provider logic |
| Widget | flutter_test | UI components in isolation |
| Integration | flutter_test | Multi-screen user flows |
| Edge Functions | Deno test | Supabase serverless functions |
| CI/CD | GitHub Actions | Automated test runs + coverage |

**Current Status:** 87 tests passing

---

## Phase 1: Foundation (Completed)

### 1.1 Test Dependencies

**File: `pubspec.yaml`**

- [x] Add `mocktail: ^1.0.4` - Mocking framework
- [x] Add `fake_async: ^1.3.1` - Async testing utilities
- [x] Verify `flutter_test` is present (sdk dependency)

### 1.2 Dependency Injection Refactoring

**Goal:** Make `SupabaseService` injectable for testing.

- [x] Create `lib/services/supabase_service_interface.dart`
  - [x] Define `ISupabaseService` abstract class
  - [x] Include auth methods (signUp, signIn, signOut, etc.)
  - [x] Include profile methods (getUserProfile, updateUserProfile)
  - [x] Include check-in methods (performCheckIn)
  - [x] Include contacts methods (getContacts, addContact, updateContact, deleteContact)
  - [x] Include FCM token method (updateFCMToken)

- [x] Refactor `lib/services/supabase_service.dart`
  - [x] Implement `ISupabaseService` interface
  - [x] Keep backward compatibility during transition

- [x] Create Riverpod provider for DI
  - [x] Add `supabaseServiceProvider` in `lib/services/service_providers.dart`
  - [x] Default to production implementation

- [x] Update consumers to use injected service
  - [x] `lib/features/auth/providers/auth_provider.dart`
  - [x] `lib/features/check_in/providers/check_in_provider.dart`
  - [x] `lib/features/contacts/providers/contacts_provider.dart`
  - [x] `lib/features/settings/providers/user_profile_provider.dart`

### 1.3 Test Infrastructure

- [x] Create `test/mocks/mock_supabase_service.dart`
- [ ] Create `test/mocks/mock_notification_service.dart`
- [x] Create `test/mocks/test_fixtures.dart` (sample data)
- [x] Create `test/helpers/pump_app.dart` (widget test helper)
- [ ] Create `test/helpers/riverpod_test_utils.dart`

---

## Phase 2: Unit Tests (Completed)

### 2.1 Validators (22 tests)

**File: `test/unit/validators_test.dart`**

- [x] `validateEmail`
  - [x] Returns null for valid email
  - [x] Returns error for empty input
  - [x] Returns error for invalid format (no @)
  - [x] Returns error for invalid format (no domain)
  - [x] Returns error for invalid format (incomplete domain)

- [x] `validatePassword`
  - [x] Returns null for valid password (8+ chars)
  - [x] Returns error for empty input
  - [x] Returns error for short password (<8 chars)

- [x] `validatePasswordConfirm`
  - [x] Returns null when passwords match
  - [x] Returns error for empty input
  - [x] Returns error when passwords don't match

- [x] `validatePhone`
  - [x] Returns null for valid phone
  - [x] Returns null for empty input (optional field)
  - [x] Returns error for invalid format
  - [x] Handles formatting characters (spaces, dashes)

- [x] `validatePhoneRequired`
  - [x] Returns null for valid phone
  - [x] Returns error for empty input (required)
  - [x] Returns error for invalid format

- [x] `validateName`
  - [x] Returns null for valid name
  - [x] Returns error for empty input
  - [x] Returns error for name >100 characters
  - [x] Accepts name with exactly 100 characters

### 2.2 Models (24 tests)

**File: `test/unit/models/user_test.dart`** (7 tests)

- [x] `AppUser.fromJson`
  - [x] Parses complete JSON correctly
  - [x] Handles missing optional fields
  - [x] Applies default values (checkInIntervalHours: 48, timezone: 'UTC')

- [x] `AppUser.toJson`
  - [x] Serializes all fields correctly
  - [x] Roundtrip (fromJson → toJson → fromJson) preserves data

- [x] `AppUser.copyWith`
  - [x] Creates new instance with updated fields
  - [x] Preserves unchanged fields

**File: `test/unit/models/emergency_contact_test.dart`** (9 tests)

- [x] `EmergencyContact.fromJson`
  - [x] Parses complete JSON correctly
  - [x] Handles null email
  - [x] Handles missing email field
  - [x] Applies default values (priority: 1, notifyOnAdd: false)

- [x] `EmergencyContact.toJson`
  - [x] Serializes all fields correctly
  - [x] Serializes null email correctly
  - [x] Roundtrip preserves data

- [x] `EmergencyContact.copyWith`
  - [x] Works correctly for all fields
  - [x] Preserves unchanged fields

**File: `test/unit/models/check_in_test.dart`** (8 tests)

- [x] `CheckIn.fromJson`
  - [x] Parses timestamps correctly
  - [x] Handles all fields
  - [x] Applies default values (wasOnTime: true)
  - [x] Handles null device_info

- [x] `CheckIn.toJson`
  - [x] Serializes correctly
  - [x] Roundtrip preserves data

- [x] `CheckIn.copyWith`
  - [x] Creates new instance with updated fields
  - [x] Can update deviceInfo

### 2.3 Providers (24 tests)

**File: `test/unit/providers/check_in_provider_test.dart`** (14 tests)

- [x] Initial state
  - [x] Returns empty state when user is null
  - [x] Returns populated state with user data

- [x] `checkIn()`
  - [x] Sets isShowingSuccess to true on start
  - [x] Calls SupabaseService.performCheckIn
  - [x] Sets error state on failure

- [x] `setInterval()`
  - [x] Calls SupabaseService.updateUserProfile
  - [x] Recalculates nextDue when interval changes

- [x] `timeRemaining` provider
  - [x] Returns null when nextDue is null
  - [x] Returns positive duration when not overdue
  - [x] Returns negative duration when overdue

- [x] `isOverdue` provider
  - [x] Returns false when remaining is null
  - [x] Returns false when remaining is positive
  - [x] Returns true when remaining is negative

- [x] `clearError()`
  - [x] Clears error state

**File: `test/unit/providers/auth_provider_test.dart`** (Deferred)

> Deferred: Requires mocking NotificationService (Firebase dependencies)

- [ ] `authState` provider
- [ ] `currentAuthUser` provider
- [ ] `currentUserProfile` provider
- [ ] `AuthNotifier.signUp`
- [ ] `AuthNotifier.signIn`
- [ ] `AuthNotifier.signOut`
- [ ] `AuthNotifier.resetPassword`

**File: `test/unit/providers/contacts_provider_test.dart`** (10 tests)

- [x] Initial state
  - [x] Starts with loading state

- [x] ContactsState
  - [x] Default values are correct
  - [x] copyWith works correctly

- [x] Helper providers (with mocked state)
  - [x] contactsCount returns correct count
  - [x] hasContacts returns true when contacts exist
  - [x] hasContacts returns false when no contacts
  - [x] canAddContact returns true when under limit
  - [x] canAddContact returns false when at limit
  - [x] contactById returns correct contact
  - [x] contactById returns null for unknown id

- [x] Max contacts limit
  - [x] ISupabaseService.maxContacts is 5

---

## Phase 3: Widget Tests

### 3.1 Shared Widgets

**File: `test/widget/widgets/app_button_test.dart`**

- [ ] Renders with label text
- [ ] Calls onPressed when tapped
- [ ] Shows loading indicator when isLoading is true
- [ ] Disables tap when isLoading is true
- [ ] Applies custom style when provided

**File: `test/widget/widgets/app_text_field_test.dart`**

- [ ] Renders with label
- [ ] Renders with hint text
- [ ] Shows error message from validator
- [ ] Obscures text when obscureText is true
- [ ] Updates controller value on input

**File: `test/widget/widgets/loading_overlay_test.dart`**

- [ ] Shows loading indicator when isLoading is true
- [ ] Hides loading indicator when isLoading is false
- [ ] Renders child widget
- [ ] Blocks interaction when loading

### 3.2 Check-In Widgets

**File: `test/widget/check_in/check_in_button_test.dart`**

- [ ] Renders "I'M OK" text
- [ ] Shows circular shape
- [ ] Triggers checkIn on tap
- [ ] Shows success state (checkmark, green)
- [ ] Provides haptic feedback (verify callback)

**File: `test/widget/check_in/countdown_timer_test.dart`**

- [ ] Displays "X days, Y hours" when >24h remaining
- [ ] Displays "X hours, Y minutes" when <24h remaining
- [ ] Displays "X minutes remaining" when <1h remaining
- [ ] Displays "OVERDUE" with red color when negative
- [ ] Changes color based on urgency (green → orange → red)

### 3.3 Contacts Widgets

**File: `test/widget/contacts/contact_card_test.dart`**

- [ ] Displays contact name
- [ ] Displays masked phone number
- [ ] Displays masked email (if provided)
- [ ] Handles null email gracefully
- [ ] Tap triggers edit callback
- [ ] Swipe triggers delete callback

---

## Phase 4: Integration Tests

### 4.1 Auth Flow

**File: `test/integration/auth_flow_test.dart`**

- [ ] Sign up flow
  - [ ] Enter email, password, confirm password
  - [ ] Tap sign up button
  - [ ] Navigates to home screen on success
  - [ ] Shows error on invalid input
  - [ ] Shows error on existing email

- [ ] Sign in flow
  - [ ] Enter email and password
  - [ ] Tap sign in button
  - [ ] Navigates to home screen on success
  - [ ] Shows error on wrong credentials

- [ ] Sign out flow
  - [ ] Tap logout in settings
  - [ ] Returns to login screen

- [ ] Password reset flow
  - [ ] Enter email
  - [ ] Tap reset button
  - [ ] Shows confirmation message

### 4.2 Check-In Flow

**File: `test/integration/check_in_flow_test.dart`**

- [ ] Check-in happy path
  - [ ] App shows countdown timer
  - [ ] Tap check-in button
  - [ ] Success animation plays
  - [ ] Timer resets to new deadline

- [ ] Overdue state
  - [ ] Timer shows "OVERDUE"
  - [ ] Visual warning displayed
  - [ ] Check-in still works

### 4.3 Contacts Flow

**File: `test/integration/contacts_flow_test.dart`**

- [ ] Add contact flow
  - [ ] Tap add button
  - [ ] Fill in name, phone, email
  - [ ] Tap save
  - [ ] Contact appears in list

- [ ] Edit contact flow
  - [ ] Tap contact card
  - [ ] Modify fields
  - [ ] Tap save
  - [ ] Changes reflected in list

- [ ] Delete contact flow
  - [ ] Swipe contact
  - [ ] Confirm deletion
  - [ ] Contact removed from list

- [ ] Contact limit
  - [ ] Add 5 contacts
  - [ ] Add button disabled or shows error

---

## Phase 5: Supabase Edge Function Tests

### 5.1 Test Setup

- [ ] Create `supabase/functions/deno.json` with test task
- [ ] Create `supabase/functions/_test_utils/mocks.ts`
  - [ ] Mock Supabase client
  - [ ] Mock Twilio API response
  - [ ] Mock Resend API response
  - [ ] Mock FCM API response

### 5.2 check-missed-checkins

**File: `supabase/functions/check-missed-checkins/index_test.ts`**

- [ ] Returns 200 with empty result when no overdue users
- [ ] Identifies overdue users correctly
- [ ] Calls send-alert for each overdue user
- [ ] Handles database errors gracefully
- [ ] Respects grace period (1 hour)

### 5.3 send-alert

**File: `supabase/functions/send-alert/index_test.ts`**

- [ ] Sends SMS via Twilio with correct message format
- [ ] Sends email via Resend with correct template
- [ ] Records alert in alerts_sent table
- [ ] Prevents duplicate alerts within 24 hours
- [ ] Handles Twilio failure gracefully
- [ ] Handles Resend failure gracefully
- [ ] Continues sending if one channel fails

### 5.4 schedule-reminders

**File: `supabase/functions/schedule-reminders/index_test.ts`**

- [ ] Identifies users needing 24h reminder
- [ ] Identifies users needing 6h reminder
- [ ] Identifies users needing 1h reminder
- [ ] Sends FCM push notification with correct payload
- [ ] Handles missing FCM token
- [ ] Skips users with notifications disabled

---

## Phase 6: CI/CD

### 6.1 GitHub Actions

**File: `.github/workflows/test.yml`**

- [ ] Create workflow file
- [ ] Configure Flutter test job
  - [ ] Checkout code
  - [ ] Setup Flutter
  - [ ] Run `flutter pub get`
  - [ ] Run `flutter test --coverage`
  - [ ] Upload coverage to Codecov

- [ ] Configure Edge Function test job
  - [ ] Checkout code
  - [ ] Setup Deno
  - [ ] Run `deno test --allow-env`

- [ ] Configure triggers
  - [ ] Run on push to main
  - [ ] Run on pull requests

### 6.2 Coverage Reporting

- [ ] Add Codecov badge to README
- [ ] Set coverage threshold (target: 80%)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-13 | Initial test PRD |
| 1.1 | 2026-01-13 | Phase 1 complete: DI refactoring, test infrastructure |
| 1.2 | 2026-01-13 | Phase 2 complete: 87 unit tests (validators, models, providers) |
