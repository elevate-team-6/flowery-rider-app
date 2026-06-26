import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/country_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/apply_form.dart';
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
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController vehicleNumberController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController nidController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  late List<CountryEntity> mockCountries;
  late List<VehicleTypeEntity> mockVehicleTypes;

  CountryEntity? selectedCountry;
  VehicleTypeEntity? selectedVehicleType;

  bool isNationalIdPicked = false;
  bool isDrivingLicensePicked = false;

  late Map<String, Map<String, dynamic>> translations;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    translations = {
      'en': {
        'country': 'Country',
        'firstName': 'First legal name',
        'enterFirstName': 'Enter first legal name',
        'enterSecondName': 'Enter second legal name',
        'secondName': 'Second legal name',
        'vehicleType': 'Vehicle type',
        'enterVehicleNumber': 'Enter vehicle number',
        'vehicleNumber': 'Vehicle number',
        'vehicleLicense': 'Vehicle license',
        'uploadVehicleLicense': 'Upload license photo',
        'enterYourEmail': 'Enter your email',
        'email': 'Email',
        'enterPhoneNumber': 'Enter phone number',
        'phoneNumber': 'Phone number',
        'enterIdNumber': 'Enter national ID number',
        'idNumber': 'ID number',
        'idImage': 'ID image',
        'uploadIdImage': 'Upload ID image',
        'enterYourPassword': 'Enter password',
        'password': 'Password',
        'confirmPassword': 'Confirm password',
      },
    };
  });

  setUp(() {
    formKey = GlobalKey<FormState>();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    vehicleNumberController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    nidController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    mockCountries = [
      const CountryEntity(
        id: '1',
        name: 'Egypt',
        isoCode: '',
        phoneCode: '',
        flag: '',
        currency: '',
      ),
      const CountryEntity(
        id: '2',
        name: 'Saudi Arabia',
        isoCode: '',
        phoneCode: '',
        flag: '',
        currency: '',
      ),
    ];

    mockVehicleTypes = [
      const VehicleTypeEntity(id: '1', type: 'Motorcycle', image: ''),
      const VehicleTypeEntity(id: '2', type: 'Car', image: ''),
    ];

    selectedCountry = null;
    selectedVehicleType = null;
    isNationalIdPicked = false;
    isDrivingLicensePicked = false;
  });

  tearDown(() {
    firstNameController.dispose();
    lastNameController.dispose();
    vehicleNumberController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nidController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    File? nationalId,
    File? drivingLicense,
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
                  body: SingleChildScrollView(
                    child: ApplyForm(
                      formKey: formKey,
                      firstNameController: firstNameController,
                      lastNameController: lastNameController,
                      vehicleNumberController: vehicleNumberController,
                      emailController: emailController,
                      phoneController: phoneController,
                      nidController: nidController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      nationalIdImage: nationalId,
                      drivingLicenseImage: drivingLicense,
                      onPickNationalIdImage: () => isNationalIdPicked = true,
                      onPickDrivingLicenseImage: () =>
                          isDrivingLicensePicked = true,
                      countries: mockCountries,
                      vehicleTypes: mockVehicleTypes,
                      selectedCountry: selectedCountry,
                      onCountryChanged: (val) => selectedCountry = val,
                      onVehicleTypeChanged: (val) => selectedVehicleType = val,
                      selectedVehicleType: selectedVehicleType,
                    ),
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

  group('ApplyForm Widget Tests', () {
    testWidgets('renders all form fields correctly', (tester) async {
      await pumpForm(tester);

      expect(find.byType(TextField), findsNWidgets(10));
      expect(find.text('First legal name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('typing in fields updates controllers', (tester) async {
      await pumpForm(tester);

      final firstNameField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Enter first legal name',
      );
      await tester.enterText(firstNameField, 'Ahmed');
      expect(firstNameController.text, 'Ahmed');

      final emailField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Email',
      );
      await tester.enterText(emailField, 'test@test.com');
      expect(emailController.text, 'test@test.com');
    });

    testWidgets('triggers image picker callbacks on tap', (tester) async {
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

      final idImgField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'ID image',
      );
      await tester.ensureVisible(idImgField);
      await tester.pumpAndSettle();

      await tester.tap(idImgField);
      await tester.pump();
      expect(isNationalIdPicked, isTrue);
    });

    testWidgets('shows file name when image is provided', (tester) async {
      final fakeFile = File('dummy/path/my_license.jpg');

      await pumpForm(tester, drivingLicense: fakeFile);

      expect(find.text('my_license.jpg'), findsOneWidget);
    });

    testWidgets('validation fails when submitting empty form', (tester) async {
      await pumpForm(tester);

      final isValid = formKey.currentState?.validate();

      expect(isValid, isFalse);
    });
  });
}
