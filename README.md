# Are You Dead?

A safety check-in app for people living alone.

[![Tests](https://github.com/haigneyc/are-you-dead/actions/workflows/test.yml/badge.svg)](https://github.com/haigneyc/are-you-dead/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/haigneyc/are-you-dead/branch/main/graph/badge.svg)](https://codecov.io/gh/haigneyc/are-you-dead)

## Overview

Core mechanic: Users check in every X days (default: 2). If they miss a check-in, their designated emergency contacts are automatically alerted via SMS and email.

## Tech Stack

- **Mobile**: Flutter + Dart
- **Backend**: Supabase (Auth, Database, Edge Functions)
- **Push**: Firebase Cloud Messaging
- **SMS**: Twilio
- **Email**: Resend

## Getting Started

### Prerequisites

- Flutter 3.24+ with Dart SDK 3.6+
- Supabase project with Edge Functions enabled
- Firebase project for FCM

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/are-you-dead.git
cd are-you-dead

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Running Tests

```bash
# Run all Flutter tests
flutter test

# Run with coverage
flutter test --coverage

# Run Edge Function tests (requires Deno)
cd supabase/functions
deno test --allow-env --allow-net
```

## Documentation

- [Product Requirements Document](docs/PRD.md)
- [Test PRD](docs/TEST_PRD.md)

## License

MIT
