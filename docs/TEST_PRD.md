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

**Current Status:** 264 tests passing (228 Flutter + 36 Edge Functions)

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
- [x] Create `test/mocks/mock_notification_service.dart`
- [x] Create `test/mocks/test_fixtures.dart` (sample data)
- [x] Create `test/helpers/pump_app.dart` (widget test helper)
- [x] Create `test/helpers/integration_test_helper.dart` (integration test helper)

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

## Phase 3: Widget Tests (Completed)

### 3.1 Shared Widgets (38 tests)

**File: `test/widget/widgets/app_button_test.dart`** (16 tests)

- [x] Renders child widget
- [x] Renders as ElevatedButton for primary variant
- [x] Renders as OutlinedButton for secondary variant
- [x] Renders as ElevatedButton for danger variant
- [x] Calls onPressed when tapped
- [x] Does not call onPressed when onPressed is null
- [x] Shows CircularProgressIndicator when isLoading is true
- [x] Shows child when isLoading is false
- [x] Disables tap when isLoading is true
- [x] Shows loading indicator for secondary variant
- [x] Shows loading indicator for danger variant
- [x] Renders full width by default
- [x] Renders without full width when fullWidth is false

**File: `test/widget/widgets/app_text_field_test.dart`** (18 tests)

- [x] Renders with label
- [x] Renders with hint text
- [x] Renders with both label and hint
- [x] Renders prefix icon
- [x] Renders suffix icon
- [x] Shows error message from validator
- [x] Shows no error when validation passes
- [x] Updates controller value on input
- [x] Calls onChanged callback
- [x] Calls onFieldSubmitted callback
- [x] Obscures text when obscureText is true
- [x] Does not obscure text when obscureText is false
- [x] Is enabled by default
- [x] Is disabled when enabled is false
- [x] Does not accept input when disabled
- [x] Defaults to single line
- [x] Supports multiple lines
- [x] Uses email keyboard type when specified
- [x] Uses phone keyboard type when specified

**File: `test/widget/widgets/loading_overlay_test.dart`** (12 tests)

- [x] Renders child widget
- [x] Renders child widget even when loading
- [x] Shows loading indicator when isLoading is true
- [x] Hides loading indicator when isLoading is false
- [x] Shows loading indicator inside a Card
- [x] Shows message when provided and loading
- [x] Does not show message when not loading
- [x] Does not show message when message is null
- [x] Overlay covers entire screen when loading
- [x] No overlay when not loading
- [x] Blocks interaction when loading
- [x] Allows interaction when not loading
- [x] Can transition from not loading to loading
- [x] Can transition from loading to not loading

### 3.2 Check-In Widgets (36 tests)

**File: `test/widget/check_in/check_in_button_test.dart`** (17 tests)

- [x] Renders "I'M OK" text in default state
- [x] Shows circular shape
- [x] Has correct dimensions (140x140)
- [x] Shows checkmark icon when isShowingSuccess is true
- [x] Uses success color when isShowingSuccess is true
- [x] Animates when transitioning to success state
- [x] Shows "OVERDUE" text when isOverdue is true
- [x] Uses error color when isOverdue is true
- [x] Uses grey color when disabled
- [x] Does not call onPressed when disabled
- [x] Calls onPressed when tapped
- [x] Triggers haptic feedback on tap
- [x] Uses Transform widget for scale animation
- [x] Success state takes priority over overdue state

**File: `test/widget/check_in/countdown_timer_test.dart`** (19 tests)

- [x] Shows "No check-in scheduled" when nextDue is null
- [x] Does not show countdown when nextDue is null
- [x] Displays "X days, Y hours" when >24h remaining
- [x] Handles singular "day" correctly
- [x] Displays "X hours, Y min" when <24h but >1h remaining
- [x] Handles singular "hour" correctly
- [x] Displays "X minutes" when <1h remaining
- [x] Handles singular "minute" correctly
- [x] Displays "OVERDUE" when time is negative
- [x] Shows "Check-in overdue!" label when overdue
- [x] Uses timerNormal color when >6h remaining
- [x] Uses timerUrgent color when <6h but >1h remaining
- [x] Uses timerCritical color when <1h remaining
- [x] Uses timerCritical color when overdue
- [x] Updates display when nextDue changes
- [x] Updates from valid time to null
- [x] Starts pulse animation when overdue
- [x] Handles exactly 0 minutes remaining
- [x] Handles exactly 24 hours remaining

### 3.3 Contacts Widgets (26 tests)

**File: `test/widget/contacts/contact_card_test.dart`** (26 tests)

- [x] Displays contact name
- [x] Displays contact initial in avatar
- [x] Displays masked phone number
- [x] Displays masked email when provided
- [x] Handles null email gracefully
- [x] Handles empty email gracefully
- [x] Shows ? for empty name
- [x] Masks long phone number correctly
- [x] Handles short phone number
- [x] Masks standard email correctly
- [x] Handles email without @ symbol
- [x] Calls onTap when card is tapped
- [x] Calls onTap when tapping contact name
- [x] Shows popup menu when more button is tapped
- [x] Calls onTap when Edit menu item is selected
- [x] Calls onDelete when Delete menu item is selected
- [x] Shows edit icon in menu
- [x] Shows delete icon in menu
- [x] Renders as a Card widget
- [x] Has CircleAvatar for contact initial
- [x] Uppercase first letter in avatar

---

## Phase 4: Integration Tests (Completed)

### 4.1 Auth Flow (25 tests)

**File: `test/integration/auth_flow_test.dart`**

- [x] Login Screen
  - [x] Displays login form elements
  - [x] Shows validation errors for empty fields
  - [x] Shows validation error for invalid email
  - [x] Shows validation error for short password
  - [x] Successful login navigates to home
  - [x] Shows error snackbar on login failure
  - [x] Navigates to signup screen
  - [x] Navigates to forgot password screen
  - [x] Toggles password visibility
  - [x] Shows loading state during sign in

- [x] Signup Screen
  - [x] Displays signup form elements
  - [x] Shows validation errors for empty required fields
  - [x] Shows error when passwords do not match
  - [x] Successful signup shows confirmation and navigates to login
  - [x] Shows error snackbar on signup failure
  - [x] Back button navigates to login
  - [x] Sign in link navigates to login

- [x] Forgot Password Screen
  - [x] Displays reset password form
  - [x] Shows validation error for empty email
  - [x] Shows validation error for invalid email
  - [x] Successful reset shows confirmation UI
  - [x] Back button navigates to login

- [x] Auth Redirects
  - [x] Unauthenticated user is redirected to login
  - [x] Authenticated user on login is redirected to home
  - [x] Authenticated user on signup is redirected to home

### 4.2 Check-In Flow (6 tests)

**File: `test/integration/check_in_flow_test.dart`**

- [x] Check-In Screen Layout
  - [x] Displays app bar with title
  - [x] Displays countdown timer widget
  - [x] Displays check-in button widget
  - [x] Displays "I'M OK" text on button

- [x] No Check-In Scheduled
  - [x] Shows "No check-in scheduled" when nextDue is null

- [x] App Shell Integration
  - [x] Check-in screen is accessible from bottom nav

> Note: Button action behavior (success state, animation) is tested in widget tests (test/widget/check_in/check_in_button_test.dart).

### 4.3 Contacts Flow (10 tests)

**File: `test/integration/contacts_flow_test.dart`**

- [x] AddContactScreen Form
  - [x] Displays form fields
  - [x] Shows validation errors for empty fields
  - [x] Shows validation error for invalid phone
  - [x] Shows validation error for invalid email
  - [x] Shows Add Contact button at bottom
  - [x] Shows info text about contact notifications

- [x] EditContactScreen Layout
  - [x] Edit screen shows Edit Contact title
  - [x] Edit screen shows Save Changes button
  - [x] Edit screen shows Delete Contact button

- [x] App Shell Integration
  - [x] Contacts screen is accessible from bottom nav

> Note: ContactsScreen layout and CRUD operations are tested in widget and unit tests.

---

## Phase 5: Supabase Edge Function Tests (Completed)

### 5.1 Test Setup

- [x] Create `supabase/functions/deno.json` with test task
- [x] Create `supabase/functions/_test_utils/mocks.ts`
  - [x] Mock Supabase client
  - [x] Mock Twilio API response
  - [x] Mock Resend API response
  - [x] Mock FCM API response

### 5.2 check-missed-checkins (9 tests)

**File: `supabase/functions/check-missed-checkins/index_test.ts`**

- [x] Returns 401 without cron secret
- [x] Returns 200 with valid cron secret
- [x] Returns empty result when no overdue users
- [x] Identifies overdue users correctly
- [x] Calls send-alert for each overdue user
- [x] Handles database errors gracefully
- [x] Respects grace period (1 hour)
- [x] Processes multiple overdue users
- [x] Sends FCM notification to user after alerts

### 5.3 send-alert (12 tests)

**File: `supabase/functions/send-alert/index_test.ts`**

- [x] Sends SMS via Twilio with correct message format
- [x] Sends email via Resend with correct template
- [x] Records alert in alerts_sent table
- [x] Prevents duplicate alerts within 24 hours
- [x] Handles Twilio failure gracefully
- [x] Handles Resend failure gracefully
- [x] Continues sending if one channel fails
- [x] Formats last check-in date correctly
- [x] Skips email if contact has no email
- [x] Skips SMS if Twilio not configured
- [x] Returns correct response format
- [x] SMS message contains required information

### 5.4 schedule-reminders (15 tests)

**File: `supabase/functions/schedule-reminders/index_test.ts`**

- [x] Returns 401 without cron secret
- [x] Returns 200 with valid cron secret
- [x] Identifies users needing 24h reminder
- [x] Identifies users needing 6h reminder
- [x] Identifies users needing 1h reminder
- [x] Sends FCM push notification with correct payload
- [x] Handles missing FCM token
- [x] Skips users with notifications disabled
- [x] Uses high priority for 1h reminder
- [x] Uses normal priority for 24h and 6h reminders
- [x] Returns results for all windows
- [x] Calculates time window correctly (30 min tolerance)
- [x] Handles FCM errors gracefully
- [x] Includes correct notification messages
- [x] Configures iOS APNs correctly

---

## Phase 6: CI/CD (Completed)

### 6.1 GitHub Actions

**File: `.github/workflows/test.yml`**

- [x] Create workflow file
- [x] Configure Flutter test job
  - [x] Checkout code
  - [x] Setup Flutter
  - [x] Run `flutter pub get`
  - [x] Verify formatting with `dart format`
  - [x] Analyze project with `flutter analyze`
  - [x] Run `flutter test --coverage`
  - [x] Upload coverage to Codecov

- [x] Configure Edge Function test job
  - [x] Checkout code
  - [x] Setup Deno
  - [x] Cache Deno dependencies
  - [x] Run `deno test --allow-env --allow-net`

- [x] Configure triggers
  - [x] Run on push to main
  - [x] Run on pull requests
  - [x] Cancel in-progress runs on new push

### 6.2 Coverage Reporting

- [x] Add Codecov badge to README
- [x] Add GitHub Actions badge to README
- [ ] Set coverage threshold (target: 80%) - Configure after initial baseline

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-13 | Initial test PRD |
| 1.1 | 2026-01-13 | Phase 1 complete: DI refactoring, test infrastructure |
| 1.2 | 2026-01-13 | Phase 2 complete: 87 unit tests (validators, models, providers) |
| 1.3 | 2026-01-13 | Phase 3 complete: 100 widget tests (AppButton, AppTextField, LoadingOverlay, CheckInButton, CountdownTimer, ContactCard) |
| 1.4 | 2026-01-13 | Phase 4 complete: 41 integration tests (auth flow, check-in flow, contacts flow) |
| 1.5 | 2026-01-13 | Phase 5 complete: 36 Edge Function tests (check-missed-checkins, send-alert, schedule-reminders) |
| 1.6 | 2026-01-13 | Phase 6 complete: GitHub Actions CI/CD workflow with coverage reporting |
| 1.7 | 2026-01-13 | CI fix: Updated Flutter 3.24.0 → 3.27.0 for Dart 3.6.1 compatibility |
