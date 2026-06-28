import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/success_apply_screen.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return _data[locale.languageCode] ?? {};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Map<String, dynamic>> translations;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await EasyLocalization.ensureInitialized();

    translations = {
      AppConstants.englishCode:
          json.decode(
                await rootBundle.loadString(
                  '${AppConstants.translationsPath}/${AppConstants.englishCode}.json',
                ),
              )
              as Map<String, dynamic>,
      AppConstants.arabicCode:
          json.decode(
                await rootBundle.loadString(
                  '${AppConstants.translationsPath}/${AppConstants.arabicCode}.json',
                ),
              )
              as Map<String, dynamic>,
    };
  });

  Future<void> pumpSuccessApplyScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        path: AppConstants.translationsPath,
        assetLoader: _InMemoryAssetLoader(translations),
        child: Builder(
          builder: (context) {
            return ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (_, _) {
                return MaterialApp(
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  home: const SuccessApplyScreen(),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('SuccessApplyScreen', () {
    testWidgets('renders correctly', (tester) async {
      await pumpSuccessApplyScreen(tester);

      expect(find.byType(Scaffold), findsOneWidget);

      expect(find.byType(ElevatedButton), findsOneWidget);

      expect(find.text(AppStrings.submitSuccess.tr()), findsOneWidget);

      expect(find.text(AppStrings.submitDescription.tr()), findsOneWidget);

      expect(find.text(AppStrings.login.tr()), findsOneWidget);
    });

    testWidgets('navigates when login button tapped', (tester) async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          fallbackLocale: const Locale('en'),
          startLocale: const Locale('en'),
          path: AppConstants.translationsPath,
          assetLoader: _InMemoryAssetLoader(translations),
          child: Builder(
            builder: (context) {
              return ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (_, _) {
                  return MaterialApp(
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    routes: {
                      AppRoutes.login: (_) => const Scaffold(
                        body: Center(child: Text('Login Screen')),
                      ),
                    },
                    home: const SuccessApplyScreen(),
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final loginButton = find.byType(ElevatedButton);

      expect(loginButton, findsOneWidget);

      await tester.ensureVisible(loginButton);

      await tester.pumpAndSettle();

      await tester.tap(loginButton);

      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('displays translated texts in arabic', (tester) async {
      await pumpSuccessApplyScreen(tester, locale: const Locale('ar'));

      expect(find.text(AppStrings.submitSuccess.tr()), findsOneWidget);

      expect(find.text(AppStrings.submitDescription.tr()), findsOneWidget);

      expect(find.text(AppStrings.login.tr()), findsOneWidget);
    });
  });
}
