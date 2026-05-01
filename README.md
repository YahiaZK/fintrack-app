# FinTrack

A gamified personal-finance app built with Flutter and Firebase. Track your income, expenses, and net worth, set goals, and level up by completing daily quests tied to healthier spending habits.

## Features

- **Auth & onboarding** — Email/password sign-in via Firebase Auth, followed by a guided onboarding flow (name, income, expenses).
- **Home dashboard** — Net-worth overview, active goals, and the day's quest preview.
- **Goals** — Create savings goals and track progress against them.
- **Quests & gamification** — Earn XP for completing finance-habit quests, with levels, ranks, and badges.
- **Tools**
  - **Transaction Manager** — Add, edit, and categorize income and expense entries.
  - **Insights** — Visualize spending with `fl_chart`-powered charts.
- **Calculator** — Built-in calculator for quick math while budgeting.
- **AI Chat** — Conversational assistant (backed by Cloud Functions) that can propose transactions for you to review.
- **Profile** — View your level, rank progression, and earned badges.

## Tech stack

- **Flutter** (Dart SDK ^3.10.7)
- **State management:** `flutter_riverpod`
- **Routing:** `go_router` with `StatefulShellRoute`
- **Backend:** Firebase — `firebase_auth`, `cloud_firestore`, `cloud_functions`
- **Charts:** `fl_chart`
- **Icons/SVG:** `flutter_svg`, Cupertino Icons

## Project structure

```
lib/
├── main.dart                # App entry, Firebase init, ProviderScope
├── firebase_options.dart    # Generated FlutterFire config (gitignored)
├── router/                  # go_router configuration & auth/onboarding redirects
├── theme/                   # Dark theme + color palette
├── models/                  # Firestore data models (Quest, Goal, UserProfile, ...)
├── providers/               # Riverpod providers (auth, user, quests, goals, chat, ...)
├── services/                # Firebase service layer (Auth, Firestore, Functions)
├── screens/                 # Feature screens (auth, onboarding, home, quests, tools, ...)
├── components/              # Reusable UI (app shell, onboarding widgets, ...)
├── widgets/                 # Overlays (level-up, tool guide)
└── utils/                   # Levels, ranks, quest helpers
```

## Getting started

### Prerequisites

- Flutter SDK matching `environment.sdk: ^3.10.7` in `pubspec.yaml`
- A Firebase project with Auth, Firestore, and Cloud Functions enabled
- The FlutterFire CLI: `dart pub global activate flutterfire_cli`

### Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Configure Firebase for this app
flutterfire configure
```

`flutterfire configure` regenerates `lib/firebase_options.dart` and the platform config files (`google-services.json`, `GoogleService-Info.plist`). These are intentionally excluded from version control — see commit `a8a0cc7`.

### Run

```bash
flutter run
```

## Firebase backend

The app expects the following Firestore collections (all scoped under each user):

- `users/{uid}` — profile, onboarding state, level, XP
- `users/{uid}/transactions` — income/expense entries
- `users/{uid}/goals` — savings goals
- `users/{uid}/quests` — generated daily/weekly quests
- `users/{uid}/chat` — AI chat history and transaction proposals

Cloud Functions back the AI chat and transaction-proposal flow.

