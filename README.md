# 🌸 Flowery Rider App

A delivery-rider app to manage orders, track deliveries, update order status, and handle profile settings, with full English/Arabic support. Built with Clean Architecture and a feature-based structure, BLoC/Cubit for state management, GetIt/Injectable for DI, and Hive for local storage. Integrated Firebase (Firestore, Crashlytics, Remote Config) and REST APIs via Dio/Retrofit with location-based delivery tracking.

## ✨ Key Features
- Secure authentication flow for riders
- Splash and onboarding experience
- Order list and detailed order views
- Live tracking and map-based delivery flow
- Order status updates and cancellation handling
- Profile management and vehicle details
- Multilingual support for English and Arabic
- Firebase-backed services for remote configuration, crash reporting, and cloud data

## 🧰 Tech Stack

| Category | Packages |
| --- | --- |
| **State Management** | `flutter_bloc`, `bloc`, `bloc_test`, `equatable` |
| **Networking** | `dio`, `retrofit`, `dio_cache_interceptor` |
| **Dependency Injection** | `get_it`, `injectable` |
| **Serialization** | `json_annotation`, `json_serializable`, `retrofit_generator` |
| **Local Storage** | `hive`, `hive_flutter`, `flutter_secure_storage`, `path_provider` |
| **Firebase** | `firebase_core`, `cloud_firestore`, `firebase_crashlytics`, `firebase_remote_config` |
| **Maps & Location** | `flutter_map`, `geolocator`, `geocoding`, `latlong2` |
| **Localization** | `easy_localization`, `intl` |
| **UI & UX** | `flutter_screenutil`, `google_fonts`, `flutter_svg`, `cached_network_image`, `lottie`, `bot_toast`, `pin_code_fields`, `image_picker`, `url_launcher`, `webview_flutter` |
| **Utilities** | `logger`, `stream_transform` |
| **Tooling** | `build_runner`, `flutter_lints`, `mockito`, `test`, `flutter_native_splash`, `flutter_launcher_icons` |

## 🏗️ Architecture

The project follows Clean Architecture, organized feature-first. Each feature is split into independent layers, keeping business logic decoupled from the UI and the data sources.

```text
lib/
├── main.dart                  # App entry point (DI, localization, Firebase, Hive)
├── config/                    # Cross-cutting infrastructure
│   ├── di/                    # Dependency injection (get_it + injectable)
│   ├── dio/                   # Dio HTTP client module
│   ├── interceptors/          # Auth / logging / cache interceptors
│   ├── cache/                 # Hive helper & local storage
│   ├── services/              # Auth, Firebase, Location, Remote Config, etc.
│   ├── error_handler/         # Centralized failure handling
│   ├── base_response/         # Generic API response wrappers
│   ├── base_state/            # Shared state primitives
│   └── validations/           # Form & input validations
├── core/                      # Shared building blocks
│   ├── entities/ · models/    # Shared domain & data models
│   ├── extensions/            # Dart/Flutter extensions
│   ├── widgets/               # Reusable widgets
│   └── utils/                 # Theme, colors, routes, endpoints, constants
└── features/                  # Feature modules
    └── <feature>/
        ├── api/               # Retrofit API clients & remote data sources
        ├── data/              # Models (request/response), data sources, repo impl
        ├── domain/            # Entities, repo contracts, use cases
        └── presentation/      # Screens, widgets, BLoC/Cubit view models
```

## Prerequisites
Before running the app, make sure you have:
- Flutter SDK 3.11 or newer
- Dart SDK compatible with your Flutter version
- Android Studio or Xcode installed
- A configured Firebase project

## Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd flowery-rider-app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Make sure Firebase is initialized correctly for Android/iOS.
   - Verify that the required Firebase configuration files are present.
4. Run the application:
   ```bash
   flutter run
   ```

## Development Commands
- Format the code:
  ```bash
  flutter format .
  ```
- Analyze the project:
  ```bash
  flutter analyze
  ```
- Run tests:
  ```bash
  flutter test
  ```

## Usage
After launching the app, riders can:
- Sign in or continue through the onboarding flow
- View assigned orders
- Open order details and tracking screens
- Update order status during delivery
- Manage profile and vehicle information

## License
This project is currently intended for internal/private use. Please contact the project maintainer for licensing details.

## 👨‍💻 Team

| Name | GitHub |
|---|---|
| Ahmed Emam | [@ahmedemam55](https://github.com/ahmedemam55) |
| Abanoub | [@abanoub6](https://github.com/abanoub6) |
| Abdekmalek Mokhtar | [@abdalmlk5](https://github.com/abdalmlk5) |
| Yousef Abdelghdar | [@yousefsinger](https://github.com/yousefsinger) |
