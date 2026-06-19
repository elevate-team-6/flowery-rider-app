import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/sign_in_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/login_form.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/remember_me_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  /// Translations keyed by language code (e.g. `en`, `ar`).
  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([SignInUseCase, SecureCacheHelper])
void main() {
  late MockSignInUseCase mockUseCase;
  late MockSecureCacheHelper mockCache;
  late LoginCubit cubit;
  late Map<String, Map<String, dynamic>> translations;

  const validEmail = 'test@test.com';
  const validPassword = 'Ahmed@123';

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
    mockUseCase = MockSignInUseCase();
    mockCache = MockSecureCacheHelper();

    // LoginScreen.initState dispatches LoadRememberedEmailEvent, which reads
    // the remembered-session keys. Default to "nothing cached" so the cubit
    // short-circuits; individual tests can override as needed.
    when(
      mockCache.readData(key: anyNamed('key')),
    ).thenAnswer((_) async => null);

    cubit = LoginCubit(mockUseCase, mockCache);

    provideDummy<BaseResponse<SignInEntity>>(ErrorBaseResponse('dummy'));
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  Future<void> pumpLoginScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    LoginCubit? loginCubit,
  }) async {
    final activeCubit = loginCubit ?? cubit;
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        // Keyed by locale so re-pumping rebuilds with a fresh controller
        // instead of reusing the previous locale's state.
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
              home: BlocProvider<LoginCubit>.value(
                value: activeCubit,
                child: const LoginScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('LoginScreen rendering', () {
    testWidgets('renders all core elements', (tester) async {
      await pumpLoginScreen(tester);

      expect(find.text(AppStrings.login.tr()), findsOneWidget);
      expect(find.text(AppStrings.email.tr()), findsOneWidget);
      expect(find.text(AppStrings.password.tr()), findsOneWidget);
      expect(find.text(AppStrings.rememberMe.tr()), findsOneWidget);
      expect(find.text(AppStrings.forgetPasswordQuestion.tr()), findsOneWidget);
      expect(find.text(AppStrings.continueText.tr()), findsOneWidget);

      expect(find.byType(LoginForm), findsOneWidget);
      expect(find.byType(RememberMeRow), findsOneWidget);
      // Email + password text fields.
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });

  group('Localization', () {
    testWidgets('shows Arabic text when the locale changes to Arabic', (
      tester,
    ) async {
      final en = translations['en']!;
      final ar = translations['ar']!;

      // Starts in English.
      await pumpLoginScreen(tester);
      expect(find.text(en['login'] as String), findsOneWidget);
      expect(find.text(en['continueText'] as String), findsOneWidget);

      // Re-render with the Arabic locale. A fresh cubit is used because the
      // event stream is single-subscription and the first screen already
      // listened to the shared one.
      final arabicCubit = LoginCubit(mockUseCase, mockCache);
      addTearDown(() async {
        if (!arabicCubit.isClosed) await arabicCubit.close();
      });
      await pumpLoginScreen(
        tester,
        locale: const Locale('ar'),
        loginCubit: arabicCubit,
      );

      // English strings are gone, Arabic strings are shown.
      expect(find.text(en['login'] as String), findsNothing);
      expect(find.text(ar['login'] as String), findsOneWidget);
      expect(find.text(ar['email'] as String), findsOneWidget);
      expect(find.text(ar['password'] as String), findsOneWidget);
      expect(find.text(ar['rememberMe'] as String), findsOneWidget);
      expect(find.text(ar['forgetPasswordQuestion'] as String), findsOneWidget);
      expect(find.text(ar['continueText'] as String), findsOneWidget);
    });
  });

  group('Password visibility toggle', () {
    testWidgets('starts obscured and toggles when the eye icon is tapped', (
      tester,
    ) async {
      await pumpLoginScreen(tester);

      expect(cubit.state.obscurePassword, isTrue);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(cubit.state.obscurePassword, isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });
  });

  group('Remember me checkbox', () {
    testWidgets('toggles rememberMe state when tapped', (tester) async {
      await pumpLoginScreen(tester);

      Checkbox checkbox() => tester.widget<Checkbox>(find.byType(Checkbox));

      expect(cubit.state.rememberMe, isFalse);
      expect(checkbox().value, isFalse);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(cubit.state.rememberMe, isTrue);
      expect(checkbox().value, isTrue);
    });
  });

  group('Continue (sign in)', () {
    testWidgets('disables the continue button and does not call the use case '
        'when fields are empty', (tester) async {
      await pumpLoginScreen(tester);

      // The button stays disabled until both fields are valid, so the empty
      // form can never trigger a sign-in.
<<<<<<< HEAD
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
=======
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
>>>>>>> f057837edb92fc8ae6725c5c9b9bc41656768ff1
      expect(button.onPressed, isNull);

      await tester.tap(find.text(AppStrings.continueText.tr()));
      await tester.pump();

      verifyNever(mockUseCase(any));
    });

    testWidgets('calls the use case with the entered credentials '
        'when the form is valid', (tester) async {
      when(
        mockUseCase(any),
      ).thenAnswer((_) => Completer<BaseResponse<SignInEntity>>().future);

      await pumpLoginScreen(tester);

      await tester.enterText(find.byKey(LoginForm.emailFieldKey), validEmail);
      await tester.enterText(
        find.byKey(LoginForm.passwordFieldKey),
        validPassword,
      );
      // Let the AnimatedBuilder rebuild so the now-valid form enables the
      // continue button before it is tapped.
      await tester.pump();

      await tester.tap(find.text(AppStrings.continueText.tr()));
      await tester.pump();

      final captured =
          verify(mockUseCase(captureAny)).captured.single as SignInRequestModel;
      expect(captured.email, validEmail);
      expect(captured.password, validPassword);
    });

    testWidgets('shows an error message when the use case returns a failure', (
      tester,
    ) async {
      const errorMessage = 'Invalid email or password';
      when(
        mockUseCase(any),
      ).thenAnswer((_) async => ErrorBaseResponse<SignInEntity>(errorMessage));

      await pumpLoginScreen(tester);

      await tester.enterText(find.byKey(LoginForm.emailFieldKey), validEmail);
      await tester.enterText(
        find.byKey(LoginForm.passwordFieldKey),
        validPassword,
      );
      // Let the AnimatedBuilder rebuild so the now-valid form enables the
      // continue button before it is tapped.
      await tester.pump();

      await tester.tap(find.text(AppStrings.continueText.tr()));
      // Drain the async sign-in flow and the error toast entrance animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      verify(mockUseCase(any)).called(1);
      // The error notification surfaces the failure message; no session is
      // cached on failure.
      expect(find.text(errorMessage), findsOneWidget);
      verifyNever(
        mockCache.writeData(key: anyNamed('key'), value: anyNamed('value')),
      );
    });
  });
}
