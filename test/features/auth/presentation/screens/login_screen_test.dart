import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
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

  final Map<String, dynamic> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => _data;
}

@GenerateMocks([SignInUseCase, SecureCacheHelper])
void main() {
  late MockSignInUseCase mockUseCase;
  late MockSecureCacheHelper mockCache;
  late LoginCubit cubit;
  late Map<String, dynamic> translations;

  const validEmail = 'test@test.com';
  const validPassword = 'Ahmed@123';

  const surface = Size(700, 1400);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    translations =
        json.decode(await rootBundle.loadString('assets/translations/en.json'))
            as Map<String, dynamic>;
  });

  setUp(() {
    mockUseCase = MockSignInUseCase();
    mockCache = MockSecureCacheHelper();
    cubit = LoginCubit(mockUseCase, mockCache);

    provideDummy<BaseResponse<SignInEntity>>(ErrorBaseResponse('dummy'));
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
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
                value: cubit,
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

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forget password?'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      expect(find.byType(LoginForm), findsOneWidget);
      expect(find.byType(RememberMeRow), findsOneWidget);
      // Email + password text fields.
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(Checkbox), findsOneWidget);
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
    testWidgets('shows validation errors and does not call the use case '
        'when fields are empty', (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      verifyNever(mockUseCase(any));
    });

    testWidgets('calls the use case with the entered credentials '
        'when the form is valid', (tester) async {
      when(
        mockUseCase(any),
      ).thenAnswer((_) => Completer<BaseResponse<SignInEntity>>().future);

      await pumpLoginScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), validEmail);
      await tester.enterText(find.byType(TextField).at(1), validPassword);

      await tester.tap(find.text('Continue'));
      await tester.pump();

      final captured =
          verify(mockUseCase(captureAny)).captured.single as SignInRequestModel;
      expect(captured.email, validEmail);
      expect(captured.password, validPassword);
    });
  });
}
