import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/country_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/apply_page.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_state.dart';

import 'apply_page_test.mocks.dart';

@GenerateMocks([ApplyCubit])
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

  late MockApplyCubit mockCubit;
  late Map<String, Map<String, dynamic>> translations;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();

    translations = {
      'en': {
        'Apply': 'Apply',
        'Welcome!!': 'Welcome!!',
        'You want to be a delivery man?\nJoin our team ':
            'You want to be a delivery man?\nJoin our team ',
        'Country': 'Country',
        'First legal name': 'First legal name',
        'Enter first legal name': 'Enter first legal name',
        'Enter second legal name': 'Enter second legal name',
        'Second legal name': 'Second legal name',
        'Vehicle type': 'Vehicle type',
        'Enter vehicle number': 'Enter vehicle number',
        'Vehicle number': 'Vehicle number',
        'Vehicle license': 'Vehicle license',
        'Upload license photo': 'Upload license photo',
        'enterYourEmail': 'Enter your email',
        'email': 'Email',
        'enterPhoneNumber': 'Enter phone number',
        'phoneNumber': 'Phone number',
        'Enter national ID number': 'Enter national ID number',
        'ID number': 'ID number',
        'ID image': 'ID image',
        'Upload ID image': 'Upload ID image',
        'enterYourPassword': 'Enter password',
        'password': 'Password',
        'confirmPassword': 'Confirm password',
        'gender': 'Gender',
        'female': 'Female',
        'male': 'Male',
      },
      'ar': {'Apply': 'تقديم', 'Welcome!!': 'أهلاً بك!!'},
    };
  });

  setUp(() {
    mockCubit = MockApplyCubit();

    final state = ApplyState(
      countriesState: BaseState<List<CountryEntity>>(data: const []),
      vehicleTypesState: BaseState<List<VehicleTypeEntity>>(data: const []),
    );

    when(mockCubit.state).thenReturn(state);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(state));
    when(
      mockCubit.eventStream,
    ).thenAnswer((_) => const Stream<BaseUiEvent>.empty());
    when(mockCubit.doIntent(any)).thenAnswer((_) async {});
  });

  Future<void> pumpPage(WidgetTester tester, {bool settle = true}) async {
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
                  home: BlocProvider<ApplyCubit>.value(
                    value: mockCubit,
                    child: const ApplyPage(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('ApplyPage', () {
    testWidgets('renders successfully', (tester) async {
      await pumpPage(tester);

      expect(find.byType(ApplyPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('calls init events', (tester) async {
      await pumpPage(tester);

      verify(mockCubit.doIntent(const GetCountriesEvent())).called(1);
      verify(mockCubit.doIntent(const GetVehicleTypesEvent())).called(1);
    });

    testWidgets('shows loading indicator', (tester) async {
      final loadingState = ApplyState(
        applyState: const BaseState(isLoading: true),
      );

      when(mockCubit.state).thenReturn(loadingState);
      when(mockCubit.stream).thenAnswer((_) => Stream.value(loadingState));

      await pumpPage(tester, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('button disabled while loading', (tester) async {
      final loadingState = ApplyState(
        applyState: const BaseState(isLoading: true),
      );

      when(mockCubit.state).thenReturn(loadingState);
      when(mockCubit.stream).thenAnswer((_) => Stream.value(loadingState));

      await pumpPage(tester, settle: false);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('subscribes to event stream', (tester) async {
      final controller = StreamController<BaseUiEvent>();

      when(mockCubit.eventStream).thenAnswer((_) => controller.stream);

      await pumpPage(tester);

      verify(mockCubit.eventStream).called(greaterThan(0));

      await controller.close();
    });
  });
}
