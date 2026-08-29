# Employee Management System

A production-style Flutter application for managing employee records, built as a Flutter Developer Assignment. Demonstrates Clean Architecture, BLoC state management, Firebase Authentication, REST API integration, local persistence, and automated testing.

## Features

### Authentication
- Email/password login and registration
- Google Sign-In
- Forgot password (email reset link)
- Persistent auth state (auto-redirect between Login and the app shell)
- Logout

### Employee Management
- View employees (Name, Email, Mobile, Country, State, District)
- Search employees by ID
- Filter by Name, Email, Mobile, or Country
- Add, edit, and view employee details
- Delete with confirmation dialog
- Pull-to-refresh
- Cascading Country → State → District picker (via the free CountriesNow API)

### UI/UX
- Bottom navigation shell: Home, Employees, Profile, Settings
- Home dashboard with live stat cards (total employees, countries, etc.)
- Light and Dark theme, persisted locally
- Loading, error, and empty states throughout
- Responsive layouts

### Persistence & Offline
- Employee list cached locally with Hive
- Falls back to cached data when offline

## Architecture

Clean Architecture with a Repository Pattern, organized by feature:

```
lib/
├── core/                  # Shared: theme, network, error handling, widgets, utils
├── features/
│   ├── auth/
│   │   ├── data/          # Models, Firebase datasource, repository impl
│   │   ├── domain/        # Entities, repository interface, usecases
│   │   └── presentation/  # Bloc, screens, widgets
│   └── employee/
│       ├── data/          # Models, remote/local datasources, repository impl
│       ├── domain/        # Entities, repository interface, usecases
│       └── presentation/  # Blocs (list + form), screens, widgets
├── injection_container.dart  # get_it dependency injection
└── main.dart
```

Each layer only depends on the layer beneath it (`presentation → domain ← data`), so the domain layer has zero Flutter/Firebase dependencies and is fully unit-testable in isolation.

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` |
| Dependency injection | `get_it` |
| Networking | `dio` |
| Auth | `firebase_auth`, `google_sign_in` |
| Local persistence | `hive` |
| Functional error handling | `dartz` (`Either<Failure, T>`) |
| Testing | `bloc_test`, `mocktail`, `mockito` |

## API

- Employee CRUD: `https://669b3f09276e45187d34eb4e.mockapi.io/api/v1`
- Country list: same base, `/country`
- State/District cascade: [CountriesNow API](https://countriesnow.space) (free, no key required)

## Getting Started

### Prerequisites
- Flutter SDK (3.4+)
- A Firebase project with Email/Password and Google sign-in providers enabled

### Setup
```bash
flutter pub get
```

Firebase config (`lib/firebase_options.dart`) is already included for this project's Firebase instance. If setting up a new Firebase project:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

For Google Sign-In on Android, add your debug SHA-1 fingerprint in Firebase Console → Project Settings → Your Android app:
```bash
cd android && ./gradlew signingReport
```

### Run
```bash
flutter run
```

> **Known issue:** `firebase_core_web` 3.11.0 currently fails to compile for web (Chrome/Edge) with recent Dart SDKs due to an upstream JS-interop typing bug. Run on Android, iOS, or Windows desktop instead until a patched version is released.

### Test
```bash
flutter test
```

## Project Status

Built incrementally through Auth → Employee CRUD → UI polish. See inline code comments and commit history for design rationale on cache-aside pattern, cascading location pickers, and Bloc state modeling.