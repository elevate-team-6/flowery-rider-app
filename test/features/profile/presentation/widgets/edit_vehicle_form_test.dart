import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/edit_vehicle_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late GlobalKey<FormState> formKey;
  late TextEditingController vehicleNumberController;

  late List<VehicleTypeEntity> vehicleTypes;
  VehicleTypeEntity? selectedVehicleType;

  bool isDrivingLicensePicked = false;

  late Map<String, Map<String, dynamic>> translations;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    translations = {
      'en': {
        'vehicleType': 'Vehicle type',
        'vehicleNumber': 'Vehicle number',
        'enterVehicleNumber': 'Enter vehicle number',
        'vehicleLicense': 'Vehicle license',
        'uploadVehicleLicense': 'Upload license photo',
      },
    };
  });

  setUp(() {
    formKey = GlobalKey<FormState>();
    vehicleNumberController = TextEditingController();

    vehicleTypes = const [
      VehicleTypeEntity(id: '1', type: 'Motorcycle', image: ''),
      VehicleTypeEntity(id: '2', type: 'Car', image: ''),
    ];

    selectedVehicleType = vehicleTypes.first;
    isDrivingLicensePicked = false;
  });

  tearDown(() {
    vehicleNumberController.dispose();
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    File? drivingLicense,
    String? drivingLicenseUrl,
  }) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        path: 'assets/translations',
        assetLoader: _InMemoryAssetLoader(translations),
        child: Builder(
          builder: (context) {
            return ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (_, _) => MaterialApp(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: Scaffold(
                  body: EditVehicleForm(
                    formKey: formKey,
                    vehicleNumberController: vehicleNumberController,
                    drivingLicenseImage: drivingLicense,
                    drivingLicenseImageUrl: drivingLicenseUrl,
                    onPickDrivingLicenseImage: () {
                      isDrivingLicensePicked = true;
                    },
                    vehicleTypes: vehicleTypes,
                    selectedVehicleType: selectedVehicleType,
                    onVehicleTypeChanged: (value) {
                      selectedVehicleType = value;
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('EditVehicleForm Widget Tests', () {
    testWidgets('renders all fields correctly', (tester) async {
      await pumpForm(tester);

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Vehicle number'), findsOneWidget);
      expect(find.text('Vehicle license'), findsOneWidget);
    });

    testWidgets('typing in vehicle number updates controller', (tester) async {
      await pumpForm(tester);

      final vehicleNumberField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Vehicle number',
      );

      await tester.enterText(vehicleNumberField, 'ABC123');

      expect(vehicleNumberController.text, 'ABC123');
    });

    testWidgets('tap vehicle license field calls picker', (tester) async {
      await pumpForm(tester);

      final licenseField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Vehicle license',
      );

      await tester.ensureVisible(licenseField);
      await tester.tap(licenseField);
      await tester.pump();

      expect(isDrivingLicensePicked, isTrue);
    });

    testWidgets('shows picked file name', (tester) async {
      final fakeFile = File('dummy/path/license.jpg');

      await pumpForm(tester, drivingLicense: fakeFile);

      expect(find.text('license.jpg'), findsOneWidget);
    });

    testWidgets('shows old uploaded file name from url', (tester) async {
      await pumpForm(
        tester,
        drivingLicenseUrl: 'https://server.com/uploads/vehicle_license.png',
      );

      expect(find.text('vehicle_license.png'), findsOneWidget);
    });

    testWidgets('validation fails when form is empty', (tester) async {
      await pumpForm(tester);

      final isValid = formKey.currentState?.validate();

      expect(isValid, isFalse);
    });
  });
}
