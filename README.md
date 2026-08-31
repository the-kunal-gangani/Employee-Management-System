<div align="center">

# Employee Management System

### A production-grade Flutter app built with Clean Architecture, BLoC, and Firebase

[![Flutter](https://img.shields.io/badge/Flutter-3.4%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![BLoC](https://img.shields.io/badge/State-BLoC-3D5AFE?style=for-the-badge)](https://bloclibrary.dev)
[![Tests](https://img.shields.io/badge/Tests-Passing-4CAF50?style=for-the-badge&logo=checkmarx&logoColor=white)](#-testing)
[![License](https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge)](#-license)

*A responsive employee management application demonstrating real-world Flutter engineering — authentication, offline-first CRUD, and a fully tested Clean Architecture, wrapped in a polished, animated UI.*

</div>

---

## Table of Contents

- [Highlights](#-highlights)
- [Screens](#-screens)
- [Features](#-features)
- [Architecture](#️-architecture)
- [Tech Stack](#️-tech-stack)
- [API](#-api)
- [Getting Started](#-getting-started)
- [Testing](#-testing)
- [Project Structure](#-project-structure)
- [Known Issues](#-known-issues)
- [License](#-license)

---

## Highlights

<table>
<tr>
<td width="50%">

** Motion & Polish**
- Hero animations — avatars morph seamlessly from list to detail
- Shimmer skeleton loading instead of bare spinners
- Animated, hand-rolled "Employees by Country" bar chart
- Swipe-to-delete with a 4-second **Undo** window

</td>
<td width="50%">

** Engineering**
- Clean Architecture — domain layer has zero Flutter/Firebase dependencies
- Repository pattern with `Either<Failure, T>` functional error handling
- Cache-aside offline support via Hive
- 70+ passing unit, BLoC, and widget tests

</td>
</tr>
</table>

---

## Screens

<div align="center">

| Login | Home Dashboard | Employee List | Employee Detail |
|:---:|:---:|:---:|:---:|
| _add screenshot_ | _add screenshot_ | _add screenshot_ | _add screenshot_ |

</div>

> Drop screenshots or a screen-recording GIF into a `/screenshots` folder and swap the placeholders above — first impressions matter.

---

## Features

<details open>
<summary><strong> Authentication</strong></summary>

- Email/password login and registration
- Google Sign-In (mobile)
- Forgot password via email reset link
- Persistent auth state — auto-redirects between Login and the app shell
- Displays the signed-in user's name, email, and profile photo
- Logout

</details>

<details open>
<summary><strong>Employee Management</strong></summary>

- View employees — Name, Email, Mobile, Country, State, District
- Search by employee ID
- Filter by Name, Email, Mobile, or Country
- Add, edit, and view employee details
- Delete with confirmation **and undo**
- Pull-to-refresh
- Cascading Country → State → District picker (free CountriesNow API)

</details>

<details open>
<summary><strong> UI/UX</strong></summary>

- Bottom navigation shell — **Home · Employees · Profile · Settings**
- Home dashboard with live stat cards and a country breakdown chart
- Light and Dark theme, persisted locally
- Loading, error, and empty states throughout
- Fully responsive layouts

</details>

<details open>
<summary><strong> Persistence & Offline</strong></summary>

- Employee list cached locally with Hive
- Falls back to cached data automatically when offline

</details>

---

## Architecture

Clean Architecture with a Repository Pattern, organized by feature. Each layer only depends on the layer beneath it, so the **domain layer is 100% pure Dart** — no Flutter, no Firebase — and fully unit-testable in isolation.

```
lib/
├── core/                       # Shared: theme, network, error handling, widgets, utils
│   └── widgets/                # Reusable: buttons, cards, shimmer, dialogs, charts
├── features/
│   ├── auth/
│   │   ├── data/                # Models, Firebase datasource, repository impl
│   │   ├── domain/               # Entities, repository interface, usecases
│   │   └── presentation/          # Bloc, screens, widgets
│   └── employee/
│       ├── data/                 # Models, remote/local datasources, repository impl
│       ├── domain/                # Entities, repository interface, usecases
│       └── presentation/           # Blocs (list + form), screens, widgets
├── injection_container.dart     # get_it dependency injection
└── main.dart
```

```
        ┌─────────────────┐
        │  Presentation    │  ← Bloc, Screens, Widgets
        └────────┬─────────┘
                 │ depends on
        ┌────────▼─────────┐
        │     Domain        │  ← Entities, Usecases, Repository interface
        │  (pure Dart)      │     (no Flutter / Firebase imports)
        └────────▲─────────┘
                 │ implements
        ┌────────┴─────────┐
        │      Data         │  ← Models, Datasources, Repository impl
        └───────────────────┘
```

---

## Tech Stack

| Layer | Package | Purpose |
|---|---|---|
| **State management** | `flutter_bloc` | Predictable, testable state |
| **DI** | `get_it` | Service locator for all layers |
| **Networking** | `dio` | REST client for the employee API |
| **Auth** | `firebase_auth`, `google_sign_in` | Email/password + Google OAuth |
| **Local persistence** | `hive` | Offline employee cache + theme prefs |
| **Error handling** | `dartz` | `Either<Failure, T>` functional results |
| **Animations** | `shimmer` | Skeleton loading states |
| **Testing** | `bloc_test`, `mocktail`, `mockito` | Unit, Bloc, and widget test mocking |

---

## API

| Purpose | Endpoint |
|---|---|
| Employee CRUD | `https://669b3f09276e45187d34eb4e.mockapi.io/api/v1/employee` |
| Country list | `https://669b3f09276e45187d34eb4e.mockapi.io/api/v1/country` |
| State / District cascade | [`countriesnow.space/api`](https://countriesnow.space) *(free, no API key)* |

---

## ⚡ Getting Started

### Prerequisites
- Flutter SDK `3.4+`
- A Firebase project with **Email/Password** and **Google** sign-in providers enabled

### Installation

```bash
git clone <your-repo-url>
cd employee_management_system
flutter pub get
```

Firebase config (`lib/firebase_options.dart`) is already wired for this project. Setting up a fresh Firebase project instead? Run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

For **Google Sign-In on Android**, register your debug SHA-1 fingerprint in Firebase Console → Project Settings → your Android app:

```bash
cd android && ./gradlew signingReport
```

### Run

```bash
flutter run
```

> See [Known Issues](#-known-issues) for a current web-only compile quirk — Android, iOS, and Windows desktop all run cleanly.

---

##  Testing

```bash
flutter test
```

**70+ tests**, all passing — zero live Firebase or network calls, everything mocked with `mocktail`.

| Layer | Coverage |
|---|---|
| Validators | Email, password, confirm-password, required, mobile |
| Domain usecases | Every Auth and Employee usecase |
| Repositories | Success paths, offline fallback, exception → Failure mapping |
| Blocs | `AuthBloc`, `EmployeeListBloc` (incl. undo-delete timing), `EmployeeFormBloc` |
| Widgets | Login screen (validation, dispatch, error snackbar), delete confirmation dialog |

---

## Project Structure

<details>
<summary>Click to expand full file tree</summary>

```
lib/
├── core/
│   ├── constants/          # API endpoints, storage keys
│   ├── error/               # Failure & Exception types
│   ├── network/              # Dio client, connectivity check
│   ├── theme/                 # Colors, text styles, light/dark ThemeData
│   ├── utils/                  # Validators
│   └── widgets/                 # CustomButton, CustomTextField, StatCard,
│                                  ShimmerPlaceholders, ConfirmationDialog, etc.
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── employee/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           └── screens/
│               ├── main_shell.dart          # Bottom nav shell
│               ├── home_tab_screen.dart      # Stats + chart + recents
│               ├── employee_dashboard_screen.dart
│               ├── employee_detail_screen.dart
│               ├── employee_form_screen.dart
│               ├── profile_tab_screen.dart
│               └── settings_tab_screen.dart
├── injection_container.dart
├── firebase_options.dart
└── main.dart

test/
├── core/
└── features/
    ├── auth/
    └── employee/
```

</details>

---

## Known Issues

> **`firebase_core_web` web compile error**
> Running on Chrome/Edge currently fails with an `isA<JSObject>()` compile error — an upstream JS-interop typing incompatibility between `firebase_core_web 3.11.0` and recent Dart SDKs. **Android, iOS, and Windows desktop are unaffected.** Run with `flutter run -d windows` or a mobile target in the meantime.

---

## License

Built as a Flutter Developer Assignment. Feel free to adapt or extend.

<div align="center">

**Made with 💙 and Flutter**

</div>