# Flowery Rider App

Flowery Rider App is a modern Flutter mobile application built for delivery riders to manage orders, track deliveries in real time, update order status, and handle profile settings with a polished user experience.

## Overview
This app provides a complete rider experience for flower delivery operations. It includes secure authentication, order management, live delivery tracking, notifications, and profile tools, all designed to be simple, fast, and reliable for daily use.

## Key Features
- Secure authentication flow for riders
- Splash and onboarding experience
- Order list and detailed order views
- Live tracking and map-based delivery flow
- Order status updates and cancellation handling
- Profile management and vehicle details
- Multilingual support for English and Arabic
- Firebase-backed services for remote configuration, crash reporting, and cloud data

## Tech Stack
- Flutter & Dart
- BLoC / Cubit for state management
- GetIt + Injectable for dependency injection
- Dio + Retrofit for API communication
- Hive for local cache/storage
- Firebase Core, Crashlytics, Remote Config, and Firestore
- Easy Localization, ScreenUtil, BotToast, Lottie, and Geolocator

## Architecture
The project follows a modular feature-based structure with clear separation between:
- Features: authentication, tracking, profile, notifications, and splash flows
- Core: shared utilities, themes, routes, constants, and reusable components
- Config: dependency injection, services, error handling, and app-level setup

## Project Structure
```text
flowery_rider_app/
├── android/
├── ios/
├── lib/
│   ├── config/
│   ├── core/
│   ├── features/
│   └── main.dart
├── assets/
├── test/
├── pubspec.yaml
└── README.md
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
