# EmpowerHER

A mobile platform that helps women grow their careers through guided learning projects, a supportive community, and job opportunities; all in one app.

## About

EmpowerHER is a Flutter + Firebase mobile app built as the final group project (Group 14) for the ALU Mobile Development summative assignment. It gives users a personalized dashboard, hands-on leveled projects with a step-by-step sandbox, a community forum for discussion, and a job board for posting and applying to opportunities — tying it all together with a shared profile and account.

## Features

- **Onboarding & Auth**: One-time welcome flow, then email/password or Google sign-in, with email verification on sign-up and a forgot-password flow.
- **Home dashboard**: Personalized greeting, overall progress tracking, current project card, and recommended projects.
- **Projects**: Leveled learning projects (Beginner, Intermediate, ...) that unlock sequentially. Each project has a guided, step-by-step sandbox where progress is saved per user and restored on reopen.
- **Community**: A forum where users can create posts, browse by tab, and reply in threaded discussions.
- **Jobs**: A job board to browse and search postings, apply with a CV link and cover letter, post new openings, and review applicants.
- **Profile**: View and edit personal details: bio, headline, location, contact info, and skills.
- **Settings**: Switch between light, dark, and system theme, and adjust text size.

## Tech stack

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.12.1`)
- **State management**: [Riverpod](https://riverpod.dev) (`flutter_riverpod`, `hooks_riverpod`, `flutter_hooks`)
- **Backend**: [Firebase](https://firebase.google.com) — Authentication (`firebase_auth`, incl. Google Sign-In) and Cloud Firestore (`cloud_firestore`)
- **Local persistence**: `shared_preferences` (theme, text scale, onboarding state)
- **UI**: Material 3, `google_fonts` (Inter/Poppins)
- **Testing**: `flutter_test`, `mocktail`
- **Linting**: `flutter_lints`

## Project structure

```
lib/
├── main.dart                # App entry point, Firebase init, theme/onboarding routing
├── firebase_options.dart    # Generated FlutterFire platform config
├── core/                    # Cross-cutting concerns shared by all features
│   ├── models/               # Base Firestore model, user model
│   ├── navigation/            # Auth gate + bottom-nav shell
│   ├── preferences/            # Theme/text-scale/onboarding persistence
│   ├── repositories/           # Auth + generic Firestore CRUD base
│   └── theme/                  # Brand colors and Material 3 theme
└── features/                # One folder per feature, each with its own screens/models/providers
    ├── auth/
    ├── onboarding/
    ├── home/
    ├── settings/
    ├── profile/                # domain/data/presentation layers + usecases
    ├── projects/                # domain/data/presentation layers + usecases
    ├── community/
    └── jobs/
```

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible with Dart `^3.12.1`
- A [Firebase](https://firebase.google.com) project (Authentication + Cloud Firestore enabled)
- The [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup) (`dart pub global activate flutterfire_cli`) for Firebase configuration

### Installation

1. Clone the repository:
   ```bash
   git clone git@github.com:MEDATTA0/mobile_dev_summative.git
   cd mobile_dev_summative
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. **Configure Firebase.** `google-services.json` / `GoogleService-Info.plist` are gitignored and not included in this repo, so you must generate your own before the app will build:
   ```bash
   flutterfire configure
   ```
   This regenerates `lib/firebase_options.dart` and downloads the platform config files for your own Firebase project. In the Firebase console, enable the **Email/Password** and **Google** sign-in providers under Authentication, and create a **Cloud Firestore** database.
4. Run the app:
   ```bash
   flutter run
   ```

## Running tests

```bash
flutter test
```

## Linting

```bash
flutter analyze
```

## Supported platforms

Android, iOS, Web, macOS, Windows, and Linux.

## Team

- Ibrahim Maâzou Djahadi
- Chipo Hameja
- Habeeb Dindi
- Joshua Agonzibwa
- Teniola Iji

## Project report

The full written submission for this project is available in [`Group14_Final_Project_Submission.pdf`](https://docs.google.com/document/d/1EneH2gjsoOQUglR124s5T9euu7u0ZXg7pqa7xk9hGsc/edit?usp=sharing).
