<div align="center">

# 🌸🛵 Flowery Rider

**The delivery-rider companion app for the Flowery flower-shop platform.**

Accept orders, follow a guided step-by-step delivery flow, stream your live location to the customer, and keep working even when the connection drops.

[![Flutter](https://img.shields.io/badge/Flutter-3.41.7-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-3DDC84)](#)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVI-6E56CF)](#-architecture)
[![Localization](https://img.shields.io/badge/i18n-EN%20%7C%20AR-orange)](#)

[![Quality Assurance](https://github.com/elevate-team-6/flowery-rider-app/actions/workflows/dart_lint.yml/badge.svg)](https://github.com/elevate-team-6/flowery-rider-app/actions/workflows/dart_lint.yml)
[![Unit Tests](https://github.com/elevate-team-6/flowery-rider-app/actions/workflows/unit-tests.yml/badge.svg)](https://github.com/elevate-team-6/flowery-rider-app/actions/workflows/unit-tests.yml)

</div>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Screenshots](#-screenshots)
- [Features](#-features)
- [Delivery Flow](#-delivery-flow)
- [Architecture](#️-architecture)
- [Project Structure](#-project-structure)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Code Generation](#️-code-generation)
- [Testing](#-testing)
- [Quality Gates & Conventions](#-quality-gates--conventions)
- [Documentation](#-documentation)
- [Team](#-team)
- [License](#-license)

---

## 🌷 Overview

Flowery Rider is the driver-side application of the Flowery platform. A rider signs up for approval, receives pending orders, accepts one, and is then walked through the delivery step by step — from the flower shop to the customer's doorstep — while the customer app watches the rider move on the map in real time.

The codebase is built on **Clean Architecture** with a strict feature-first, 4-layer split, **BLoC/Cubit** in an **MVI** style (events in, states + one-shot UI events out), **GetIt + Injectable** for DI, and a **zero-nullability domain layer**: every domain entity is fully non-nullable, so no null-handling logic ever leaks into the UI. The rules that keep it that way are documented in [`WORKING_STANDARDS.md`](WORKING_STANDARDS.md) and enforced in CI.

---

## 📸 Screenshots

<img width="1824" height="862" alt="Image" src="https://github.com/user-attachments/assets/48793e2b-31c7-497f-a240-b90a92d14c73" />

---

## ✨ Features

### 🔐 Authentication & Onboarding
- Rider application (apply) flow with vehicle type, country, and document data
- Sign in with secure token storage, "remember me", and auto-login on launch
- Full password recovery: forgot password → OTP verification → reset

### 📦 Orders
- Pending orders feed with pull-to-refresh, pagination, and skeleton loading
- Accept an order and open the guided delivery flow
- Delivered-orders history with a summary section, paginated list, and per-order details
- Lottie-based empty states and centralized error handling

### 🚚 Live Delivery & Tracking
- 6-step guided delivery flow with a visual step indicator
- Live rider location streamed to Firestore so the customer sees the rider move
- Route drawing over OpenStreetMap via OSRM, with retry on failure
- Pickup and drop-off maps with distance/ETA pills and route status chips
- One-tap call or WhatsApp to the store and the customer
- **Crash-safe resume**: the active order and its current step are cached in Hive, so closing the app mid-delivery resumes exactly where the rider stopped — including live tracking

### 🔔 Customer Notifications
- Order progress pushed to the customer at each milestone (Accepted → Preparing → On the way → Delivered / Canceled)
- FCM HTTP v1 with service-account credentials fetched from Firestore, so no secrets are shipped in the binary

### 👤 Profile
- View and edit profile, upload a photo, edit vehicle information
- Change password, terms & about pages via in-app WebView

### 🌐 Platform
- Full English / Arabic localization with live locale switching (no state reset)
- Responsive sizing with ScreenUtil and a single centralized theme
- Firebase Crashlytics for crash reporting

---

## 🚚 Delivery Flow

Once an order is accepted, the rider advances through a single action button. Each step updates the backend, the local cache, and the customer's notification state.

| Step | Rider action | Backend state | Customer notified |
|:---:|---|---|---|
| 1 | Arrived at pickup point | `inProgress` | Accepted |
| 2 | Picked | `inProgress` | Preparing |
| 3 | Start deliver | `inProgress` | — |
| 4 | Arrived to the user | `inProgress` | On the way 📍 *live tracking starts* |
| 5 | Delivered to the user | `inProgress` | — |
| 6 | Done | `completed` | Delivered ✅ *tracking stops, cache cleared* |

> Live location streaming is owned by `OrderDetailsCubit`, not the map screen — it keeps running from step 4 until the order is delivered or canceled, whether or not the map is open.

---

## 🏗️ Architecture

Clean Architecture, organized feature-first. Every feature is split into exactly four layers, and dependencies only ever point inward toward the domain.

```
┌──────────────────────────────────────────────────────────────┐
│  presentation/   Screens · Widgets · Cubits (MVI)            │
│                  events ↓            states + uiEvents ↑     │
├──────────────────────────────────────────────────────────────┤
│  domain/         Entities (non-nullable) · Repo contracts    │
│                  Use cases (single `call`)                   │
├──────────────────────────────────────────────────────────────┤
│  data/           Request/Response DTOs · toEntity() mapping  │
│                  Repository implementations                  │
├──────────────────────────────────────────────────────────────┤
│  api/            Retrofit clients · Remote data sources      │
└──────────────────────────────────────────────────────────────┘
        ↕ Dio (interceptors)   ↕ Firestore   ↕ Hive / Secure Storage
```

**Principles enforced across the codebase**

| Principle | What it means here |
|---|---|
| **Zero-nullability domain** | Entities are `final`, non-nullable, `Equatable`, pure Dart — no annotations |
| **Boundary rule** | All server nullability is resolved inside `toEntity()`: mandatory fields throw, optional fields get safe defaults |
| **Mapping safety** | Repositories wrap `toEntity()` in try/catch and return `ErrorBaseResponse` — the UI can never hang on a loading state |
| **MVI cubits** | `BaseCubit<State, BaseUiEvent>` with composite `BaseState` per operation; side effects go through the `uiEvents` stream |
| **Rebuild discipline** | Every `BlocBuilder` wraps the smallest possible subtree and declares `buildWhen` |
| **No hardcoding** | Strings, colors, dimensions, and endpoints live in `lib/core/utils/` |

---

## 📁 Project Structure

```text
lib/
├── main.dart                    # Entry point: Firebase → DI → Hive → localization
├── config/                      # Cross-cutting infrastructure
│   ├── base_cubit/              # BaseCubit (MVI) + shared cubit plumbing
│   ├── base_state/              # BaseState<T>: loading / data / error
│   ├── base_response/           # BaseResponse<T>: Success | Error
│   ├── base_ui_event/           # One-shot UI side effects
│   ├── base_ui_handler/         # UiEventHandler mixin for screens
│   ├── di/                      # get_it + injectable wiring
│   ├── dio/                     # HTTP clients (app + external)
│   ├── interceptors/            # Auth & logging interceptors
│   ├── cache/                   # Hive helper
│   ├── services/                # Auth, Firebase, Location, MultiPart
│   ├── error_handler/           # Centralized API error handling
│   └── validations/             # Form & input validation
├── core/                        # Shared building blocks
│   ├── entities/ · models/      # Cross-feature domain & data models
│   ├── extensions/              # Dart/Flutter extensions
│   ├── widgets/                 # Reusable widgets
│   ├── exceptions/              # Typed exceptions
│   └── utils/                   # Theme, colors, strings, routes, endpoints
└── features/
    ├── auth/                    # Apply, sign in, forgot/reset password
    ├── tracking/                # Home, orders, order details, delivery map
    ├── notification/            # Customer progress notifications (FCM v1)
    ├── profile/                 # Profile, vehicle, change password
    ├── mainLayout/              # Bottom navigation shell
    └── splash/                  # Splash & session routing
        └── <feature>/
            ├── api/             # Retrofit clients + remote data source impls
            ├── data/            # DTOs, data source contracts, repo impls
            ├── domain/          # Entities, repo contracts, use cases
            └── presentation/    # Screens, widgets, view models
```

---

## 🧰 Tech Stack

| Category | Packages |
|---|---|
| **State Management** | `flutter_bloc`, `bloc`, `equatable` |
| **Networking** | `dio`, `retrofit`, `dio_cache_interceptor` |
| **Dependency Injection** | `get_it`, `injectable` |
| **Serialization** | `json_annotation`, `json_serializable`, `retrofit_generator` |
| **Local Storage** | `hive`, `hive_flutter`, `flutter_secure_storage`, `path_provider` |
| **Firebase** | `firebase_core`, `cloud_firestore`, `firebase_crashlytics`, `firebase_remote_config` |
| **Maps & Location** | `flutter_map` (OpenStreetMap), `geolocator`, `geocoding`, `latlong2`, OSRM routing |
| **Localization** | `easy_localization`, `intl` |
| **UI & UX** | `flutter_screenutil`, `google_fonts`, `flutter_svg`, `cached_network_image`, `lottie`, `skeletonizer`, `bot_toast`, `pin_code_fields`, `image_picker`, `url_launcher`, `webview_flutter` |
| **Utilities** | `logger`, `stream_transform`, `googleapis_auth` |
| **Testing** | `flutter_test`, `bloc_test`, `mockito` |
| **Tooling** | `build_runner`, `flutter_lints`, `flutter_native_splash`, `flutter_launcher_icons` |

---

## 🚀 Getting Started

### Prerequisites

| Requirement | Version |
|---|---|
| Flutter SDK | `3.41.7` (stable) — the version pinned in CI |
| Dart SDK | `^3.11.0` |
| IDE | Android Studio / VS Code with the Flutter plugin |
| Platform tooling | Android SDK, or Xcode for iOS |
| Firebase | A configured Firebase project (Firestore, Crashlytics, Cloud Messaging) |

### Setup

**1. Clone and install dependencies**

```bash
git clone https://github.com/elevate-team-6/flowery-rider-app.git
cd flowery-rider-app
flutter pub get
```

**2. Add the Firebase configuration files**

These are intentionally **not** committed (see `.gitignore`) and must be supplied per environment:

| File | Location |
|---|---|
| `google-services.json` | `android/app/` |
| `GoogleService-Info.plist` | `ios/Runner/` |
| `firebase_options.dart` | `lib/` |

The easiest way to generate all three:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

**3. Generate the code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**4. Run the app**

```bash
flutter run
```

### Backend

The app talks to the Flowery REST API at `https://flower.elevateegy.com/api/v1` (see [`app_end_points.dart`](lib/core/utils/app_end_points.dart)), plus:

- **Cloud Firestore** — live rider location, customer notification state, and the FCM service-account config (`app_configs/fcm`)
- **OSRM** — turn-by-turn route geometry for the delivery map

---

## ⚙️ Code Generation

Injectable, Retrofit, JsonSerializable, and Mockito all rely on generated files, which are **not** committed. Regenerate them after pulling, after changing any annotated class, and before running tests:

```bash
# One-off build
dart run build_runner build --delete-conflicting-outputs

# Watch mode while developing
dart run build_runner watch --delete-conflicting-outputs
```

---

## 🧪 Testing

The suite currently covers **250 tests across 37 files** — repositories, use cases, cubits, and widget tests.

```bash
flutter test                              # Run everything
flutter test test/features/tracking       # Run one feature
flutter test --coverage                   # With coverage report
```

**Conventions**

- `mockito` for mocks (`@GenerateMocks` → run `build_runner`)
- `blocTest` for state transitions, `expectLater` for `uiEvents` side effects
- Every success **and** failure path is covered, including `toEntity()` throwing on missing mandatory fields
- Widget tests wrap the tree in `EasyLocalization` + `ScreenUtilInit`, since the UI reads `context.locale` to rebuild on locale changes

---

## ✅ Quality Gates & Conventions

Four GitHub Actions workflows guard `develop` and `master`:

| Workflow | Runs on | Checks |
|---|---|---|
| **Quality Assurance** | push + PR | `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos --fatal-warnings` |
| **Unit Tests** | PR | `flutter test` after full code generation |
| **Validate PR Title** | PR | Conventional-commit title format |
| **Validate Branch Name** | PR | Team branch naming pattern |

**Run the same checks locally before pushing:**

```bash
dart format .
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

**Branch naming**

```
<type>/FA6-<ticket>-<description>      # feature | bugfix | hotfix | refactor
example: feature/FA6-74-map
```

**PR titles**

```
<type>(<scope>): <description>         # feat | fix | docs | style | refactor
                                       # test | chore | perf | build | ci
example: feat(tracking): add live rider location
```

---

## 📚 Documentation

| Document | Contents |
|---|---|
| [`WORKING_STANDARDS.md`](WORKING_STANDARDS.md) | The mandatory coding standards: layering, entity rules, cubit patterns, UI rules, testing |
| [`docs/`](docs/) | Per-feature docs — API details, business rules, and modification history |

Per the standards, **a doc in `docs/<feature>.md` must exist before work on a feature begins.**

---

## 👨‍💻 Team

| Name | GitHub |
|---|---|
| Ahmed Emam | [@ahmedemam55](https://github.com/ahmedemam55) |
| Abanoub | [@abanoub6](https://github.com/abanoub6) |
| Abdelmalek Mokhtar | [@abdalmlk5](https://github.com/abdalmlk5) |
| Yousef Abdelghdar | [@yousefsinger](https://github.com/yousefsinger) |




