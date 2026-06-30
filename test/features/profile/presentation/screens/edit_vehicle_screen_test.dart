import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:flowery_rider_app/features/profile/presentation/screens/edit_vehicle_screen.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_states.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/edit_vehicle_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_vehicle_screen_test.mocks.dart';

@GenerateMocks([EditVehicleCubit])
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

  late MockEditVehicleCubit mockCubit;
  late DriverEntity driver;

  late Map<String, Map<String, dynamic>> translations;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    translations = {
      'en': {
        'editProfile': 'Edit Profile',
        'vehicleType': 'Vehicle Type',
        'vehicleNumber': 'Vehicle Number',
        'enterVehicleNumber': 'Enter Vehicle Number',
        'vehicleLicense': 'Vehicle License',
        'uploadVehicleLicense': 'Upload Vehicle License',
        'update': 'Update',
      },
    };
  });

  setUp(() {
    mockCubit = MockEditVehicleCubit();

    driver = const DriverEntity(
      id: '1',
      vehicleType: '1',
      vehicleNumber: 'ABC123',
      vehicleLicense: 'license.jpg',
      country: '',
      firstName: '',
      lastName: '',
      nid: '',
      nidImg: '',
      email: '',
      gender: '',
      phone: '',
      photo: '',
      role: '',
      name: '',
    );

    final state = EditVehicleState(
      hasChanges: false,
      vehicleTypesState: BaseState<List<VehicleTypeEntity>>(
        data: const [VehicleTypeEntity(id: '1', type: 'Motorcycle', image: '')],
      ),
      selectedVehicleType: const VehicleTypeEntity(
        id: '1',
        type: 'Motorcycle',
        image: '',
      ),
    );

    when(mockCubit.state).thenReturn(state);
    when(mockCubit.stream).thenAnswer((_) => Stream.value(state));
    when(
      mockCubit.eventStream,
    ).thenAnswer((_) => const Stream<BaseUiEvent>.empty());

    when(mockCubit.doIntent(any)).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester, {bool settle = true}) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
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
                  home: BlocProvider<EditVehicleCubit>.value(
                    value: mockCubit,
                    child: EditVehicleScreen(driver: driver),
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

  group('EditVehicleScreen', () {
    testWidgets('renders successfully', (tester) async {
      await pumpScreen(tester);

      expect(find.byType(EditVehicleScreen), findsOneWidget);
      expect(find.byType(EditVehicleForm), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls initialize events', (tester) async {
      await pumpScreen(tester);

      verify(
        mockCubit.doIntent(argThat(isA<InitializeEditVehicleEvent>())),
      ).called(1);

      verify(mockCubit.doIntent(const GetVehicleTypesEvent())).called(1);
    });

    testWidgets('prefills vehicle number', (tester) async {
      await pumpScreen(tester);

      expect(find.text('ABC123'), findsOneWidget);
    });

    testWidgets('button disabled when hasChanges is false', (tester) async {
      await pumpScreen(tester);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('button enabled when hasChanges is true', (tester) async {
      final newState = EditVehicleState(
        hasChanges: true,
        vehicleTypesState: BaseState(
          data: const [
            VehicleTypeEntity(id: '1', type: 'Motorcycle', image: ''),
          ],
        ),
        selectedVehicleType: const VehicleTypeEntity(
          id: '1',
          type: 'Motorcycle',
          image: '',
        ),
      );

      when(mockCubit.state).thenReturn(newState);
      when(mockCubit.stream).thenAnswer((_) => Stream.value(newState));

      await pumpScreen(tester);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      expect(button.onPressed, isNotNull);
    });

    testWidgets('subscribes to event stream', (tester) async {
      final controller = StreamController<BaseUiEvent>();

      when(mockCubit.eventStream).thenAnswer((_) => controller.stream);

      await pumpScreen(tester);

      verify(mockCubit.eventStream).called(greaterThan(0));

      await controller.close();
    });

    testWidgets('tap update button sends submit event', (tester) async {
      final newState = EditVehicleState(
        hasChanges: true,
        drivingLicenseImageUrl: 'https://example.com/license.jpg',
        vehicleTypesState: BaseState(
          data: const [
            VehicleTypeEntity(id: '1', type: 'Motorcycle', image: ''),
          ],
        ),
        selectedVehicleType: const VehicleTypeEntity(
          id: '1',
          type: 'Motorcycle',
          image: '',
        ),
      );

      when(mockCubit.state).thenReturn(newState);
      when(mockCubit.stream).thenAnswer((_) => Stream.value(newState));

      await pumpScreen(tester);
      await tester.enterText(find.byType(TextFormField).at(0), 'ABC123');

      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(
        mockCubit.doIntent(
          argThat(
            isA<EditVehicleSubmitEvent>().having(
              (e) => e.vehicleNumber,
              'vehicleNumber',
              'ABC123',
            ),
          ),
        ),
      ).called(1);
    });
  });
}
