// ignore_for_file: uri_does_not_exist, undefined_identifier
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../firebase_options.dart';

class FirebaseService {
  static Future<void> init() async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Firebase Crashlytics has no web SDK/plugin — every call to its native
    // methods throws (e.g. "isCrashlyticsCollectionEnabled" assertion
    // failures) when running on the web. Skip wiring it up entirely on web;
    // Flutter/Dart errors still print to the browser console via
    // FlutterError's default handler.
    if (kIsWeb) return;

    // Crashlytics - Flutter errors
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      originalOnError?.call(details);
    };

    // Crashlytics - Dart async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
