import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/logout_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/profile_screen.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/logout_view_model/logout_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  /// Translations keyed by language code (e.g. `en`, `ar`).
  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([LogoutUseCase, SecureCacheHelper])
void main() {
  late MockLogoutUseCase mockUseCase;
  late MockSecureCacheHelper mockCache;
  late LogoutCubit cubit;
  late Map<String, Map<String, dynamic>> translations;

  const surface = Size(700, 1400);

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

  setUp(() {
    mockUseCase = MockLogoutUseCase();
    mockCache = MockSecureCacheHelper();
    cubit = LogoutCubit(mockUseCase, mockCache);

    provideDummy<BaseResponse<LogoutEntity>>(ErrorBaseResponse('dummy'));
    when(mockCache.deleteData(key: anyNamed('key'))).thenAnswer((_) async {});
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  Future<void> pumpProfileScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        key: ValueKey(locale),
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: AppConstants.translationsPath,
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        assetLoader: _InMemoryAssetLoader(translations),
        child: Builder(
          builder: (context) => ScreenUtilInit(
            designSize: surface,
            builder: (_, _) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              debugShowCheckedModeBanner: false,
              builder: BotToastInit(),
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(child: Text('route:${settings.name}')),
                ),
              ),
              home: BlocProvider<LogoutCubit>.value(
                value: cubit,
                child: const ProfileView(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ProfileScreen rendering', () {
    testWidgets('renders the logout button', (tester) async {
      await pumpProfileScreen(tester);

      expect(find.byKey(ProfileView.logoutButtonKey), findsOneWidget);
      expect(find.text(AppStrings.profile.tr()), findsOneWidget);
    });
  });

  group('Logout confirmation dialog', () {
    testWidgets('shows the confirmation dialog when logout is tapped', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.byKey(ProfileView.logoutButtonKey));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.confirmLogout.tr()), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, AppStrings.logout.tr()),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(OutlinedButton, AppStrings.cancel.tr()),
        findsOneWidget,
      );
    });

    testWidgets('does not call the use case when the dialog is cancelled', (
      tester,
    ) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.byKey(ProfileView.logoutButtonKey));
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(OutlinedButton, AppStrings.cancel.tr()),
      );
      await tester.pumpAndSettle();

      verifyNever(mockUseCase());
    });

    testWidgets('calls the use case when logout is confirmed', (tester) async {
      when(
        mockUseCase(),
      ).thenAnswer((_) => Completer<BaseResponse<LogoutEntity>>().future);

      await pumpProfileScreen(tester);

      await tester.tap(find.byKey(ProfileView.logoutButtonKey));
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(ElevatedButton, AppStrings.logout.tr()),
      );
      await tester.pump();

      verify(mockUseCase()).called(1);
    });

    testWidgets('navigates to login and clears session on success', (
      tester,
    ) async {
      when(mockUseCase()).thenAnswer(
        (_) async =>
            SuccessBaseResponse(const LogoutEntity(message: 'success')),
      );

      await pumpProfileScreen(tester);

      await tester.tap(find.byKey(ProfileView.logoutButtonKey));
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(ElevatedButton, AppStrings.logout.tr()),
      );
      await tester.pumpAndSettle();

      verify(mockUseCase()).called(1);
      verify(mockCache.deleteData(key: anyNamed('key'))).called(2);
      expect(find.text('route:login'), findsOneWidget);
    });
  });
}
