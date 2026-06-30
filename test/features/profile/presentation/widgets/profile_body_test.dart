import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/core/widgets/custom_flower_loading.dart';
import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/profile_view_model/profile_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/profile_view_model/profile_states.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/profile_body.dart';

import 'profile_body_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  /// Translations keyed by language code (e.g. `en`, `ar`).
  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([ProfileCubit])
void main() {
  late MockProfileCubit mockProfileCubit;
  late StreamController<BaseUiEvent> uiEventStreamController;
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

  setUp(() {
    mockProfileCubit = MockProfileCubit();
    uiEventStreamController = StreamController<BaseUiEvent>.broadcast();

    when(
      mockProfileCubit.eventStream,
    ).thenAnswer((_) => uiEventStreamController.stream);

    when(mockProfileCubit.close()).thenAnswer((_) async {});
    when(mockProfileCubit.doEvent(any)).thenAnswer((_) {});
  });

  tearDown(() async {
    await uiEventStreamController.close();
  });

  Widget createWidgetUnderTest() {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: AppConstants.translationsPath,
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      assetLoader: _InMemoryAssetLoader(translations),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) {
          return Builder(
            builder: (context) {
              return MaterialApp(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: BlocProvider<ProfileCubit>.value(
                  value: mockProfileCubit,
                  child: const ProfileBody(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  group('ProfileBody Widget Tests', () {
    testWidgets('should show loading widget when profile state is loading', (
      tester,
    ) async {
      final state = ProfileStates(
        profileState: const BaseState(isLoading: true),
      );

      when(mockProfileCubit.state).thenReturn(state);

      when(mockProfileCubit.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(LoadingDialog), findsOneWidget);
    });

    testWidgets('should display driver information', (tester) async {
      const driver = DriverEntity(
        firstName: 'Ahmed',
        lastName: 'Mustafa',
        email: 'ahmed@flowery.com',
        phone: '01012345678',
        vehicleType: 'Motorcycle',
        vehicleNumber: '123 XYZ',
        photo: '',
      );

      final state = ProfileStates(profileState: BaseState(data: driver));

      when(mockProfileCubit.state).thenReturn(state);

      when(
        mockProfileCubit.stream,
      ).thenAnswer((_) => Stream<ProfileStates>.fromIterable([state]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Ahmed Mustafa'), findsOneWidget);

      expect(find.text('ahmed@flowery.com'), findsOneWidget);

      expect(find.text('01012345678'), findsOneWidget);

      expect(find.text('Motorcycle'), findsOneWidget);

      expect(find.text('123 XYZ'), findsOneWidget);
    });
  });
}
