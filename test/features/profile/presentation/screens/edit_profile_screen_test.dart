// import 'dart:async';
// import 'dart:convert';

// import 'package:bot_toast/bot_toast.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flowery_rider_app/config/base_response/base_response.dart';
// import 'package:flowery_rider_app/core/utils/app_constants.dart';
// import 'package:flowery_rider_app/core/utils/app_strings.dart';
// import 'package:flowery_rider_app/core/widgets/custom_gender_selector.dart';
// import 'package:flowery_rider_app/features/profile/data/models/request/edit_profile_request.dart';
// import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';
// import 'package:flowery_rider_app/features/profile/domain/use_cases/edit_profile_use_case.dart';
// import 'package:flowery_rider_app/features/profile/domain/use_cases/get_profile_data_use_case.dart';
// import 'package:flowery_rider_app/features/profile/domain/use_cases/upload_photo_use_case.dart';
// import 'package:flowery_rider_app/features/profile/presentation/screens/edit_profile_screen.dart';
// import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_cubit.dart';
// import 'package:flowery_rider_app/features/profile/presentation/widgets/edit_profile_avatar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// // ignore: depend_on_referenced_packages
// import 'package:shared_preferences/shared_preferences.dart';

// import 'edit_profile_screen_test.mocks.dart';

// class _InMemoryAssetLoader extends AssetLoader {
//   const _InMemoryAssetLoader(this._data);

//   /// Translations keyed by language code (e.g. `en`, `ar`).
//   final Map<String, Map<String, dynamic>> _data;

//   @override
//   Future<Map<String, dynamic>> load(String path, Locale locale) async =>
//       _data[locale.languageCode] ?? const {};
// }

// @GenerateMocks([EditProfileUseCase, UploadPhotoUseCase, GetProfileDataUseCase])
// void main() {
//   late MockEditProfileUseCase mockEditUseCase;
//   late MockUploadPhotoUseCase mockUploadUseCase;
//   late MockGetProfileDataUseCase mockGetProfileUseCase;
//   late EditProfileCubit cubit;
//   late Map<String, Map<String, dynamic>> translations;

//   // photo is null so the avatar shows the placeholder icon instead of trying
//   // to load a network image during the widget test.
//   const driver = DriverEntity(
//     id: '1',
//     firstName: 'Ahmed',
//     lastName: 'Ali',
//     email: 'ahmed@test.com',
//     phone: '+201030313971',
//     gender: 'male',
//   );

//   const surface = Size(700, 1400);

//   setUpAll(() async {
//     TestWidgetsFlutterBinding.ensureInitialized();
//     SharedPreferences.setMockInitialValues({});
//     await EasyLocalization.ensureInitialized();

//     translations = {
//       AppConstants.englishCode:
//           json.decode(
//                 await rootBundle.loadString(
//                   '${AppConstants.translationsPath}/${AppConstants.englishCode}.json',
//                 ),
//               )
//               as Map<String, dynamic>,
//       AppConstants.arabicCode:
//           json.decode(
//                 await rootBundle.loadString(
//                   '${AppConstants.translationsPath}/${AppConstants.arabicCode}.json',
//                 ),
//               )
//               as Map<String, dynamic>,
//     };
//   });

//   setUp(() {
//     mockEditUseCase = MockEditProfileUseCase();
//     mockUploadUseCase = MockUploadPhotoUseCase();
//     mockGetProfileUseCase = MockGetProfileDataUseCase();
//     cubit = EditProfileCubit(
//       mockEditUseCase,
//       mockUploadUseCase,
//       mockGetProfileUseCase,
//     );

//     provideDummy<BaseResponse<DriverEntity>>(ErrorBaseResponse('dummy'));
//   });

//   tearDown(() async {
//     if (!cubit.isClosed) await cubit.close();
//   });

//   Future<void> pumpEditProfileScreen(
//     WidgetTester tester, {
//     Locale locale = const Locale('en'),
//     EditProfileCubit? editCubit,
//   }) async {
//     final activeCubit = editCubit ?? cubit;
//     tester.view.physicalSize = surface;
//     tester.view.devicePixelRatio = 1.0;
//     addTearDown(tester.view.resetPhysicalSize);
//     addTearDown(tester.view.resetDevicePixelRatio);

//     await tester.pumpWidget(
//       EasyLocalization(
//         key: ValueKey(locale),
//         supportedLocales: const [Locale('en'), Locale('ar')],
//         path: AppConstants.translationsPath,
//         fallbackLocale: const Locale('en'),
//         startLocale: locale,
//         assetLoader: _InMemoryAssetLoader(translations),
//         child: Builder(
//           builder: (context) => ScreenUtilInit(
//             designSize: surface,
//             builder: (_, _) => MaterialApp(
//               localizationsDelegates: context.localizationDelegates,
//               supportedLocales: context.supportedLocales,
//               locale: context.locale,
//               debugShowCheckedModeBanner: false,
//               builder: BotToastInit(),
//               home: BlocProvider<EditProfileCubit>.value(
//                 value: activeCubit,
//                 child: const EditProfileScreen(driver: driver),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//     await tester.pumpAndSettle();
//   }

//   /// Finds the [EditableText] inside the [CustomTextField] carrying [label]
//   /// so a specific form field can be typed into.
//   Finder fieldByLabel(String label) => find.descendant(
//     of: find.ancestor(
//       of: find.text(label),
//       matching: find.byType(TextFormField),
//     ),
//     matching: find.byType(EditableText),
//   );

//   ElevatedButton updateButton(WidgetTester tester) =>
//       tester.widget<ElevatedButton>(find.byType(ElevatedButton));

//   group('EditProfileScreen rendering', () {
//     testWidgets('renders the form pre-filled with the driver data', (
//       tester,
//     ) async {
//       await pumpEditProfileScreen(tester);

//       expect(find.text(AppStrings.editProfile.tr()), findsWidgets);
//       expect(find.text(AppStrings.firstName.tr()), findsOneWidget);
//       expect(find.text(AppStrings.lastName.tr()), findsOneWidget);
//       expect(find.text(AppStrings.phoneNumber.tr()), findsOneWidget);
//       expect(find.byType(EditProfileAvatar), findsOneWidget);
//       expect(find.byType(CustomGenderSelector), findsOneWidget);

//       // Fields are seeded from the driver (phone shown in local format).
//       expect(find.text('Ahmed'), findsOneWidget);
//       expect(find.text('Ali'), findsOneWidget);
//       expect(find.text('ahmed@test.com'), findsOneWidget);
//       expect(find.text('01030313971'), findsOneWidget);
//     });

//     testWidgets('keeps the update button disabled until a field changes', (
//       tester,
//     ) async {
//       await pumpEditProfileScreen(tester);

//       expect(updateButton(tester).onPressed, isNull);
//     });
//   });

//   group('Form dirty tracking', () {
//     testWidgets('enables the update button when a field is edited', (
//       tester,
//     ) async {
//       await pumpEditProfileScreen(tester);

//       await tester.enterText(
//         fieldByLabel(AppStrings.firstName.tr()),
//         'Mohamed',
//       );
//       await tester.pump();

//       expect(cubit.state.isFormChanged, isTrue);
//       expect(updateButton(tester).onPressed, isNotNull);
//     });

//     testWidgets('disables the button again when the value reverts', (
//       tester,
//     ) async {
//       await pumpEditProfileScreen(tester);

//       await tester.enterText(
//         fieldByLabel(AppStrings.firstName.tr()),
//         'Mohamed',
//       );
//       await tester.pump();
//       expect(cubit.state.isFormChanged, isTrue);

//       await tester.enterText(fieldByLabel(AppStrings.firstName.tr()), 'Ahmed');
//       await tester.pump();

//       expect(cubit.state.isFormChanged, isFalse);
//       expect(updateButton(tester).onPressed, isNull);
//     });
//   });

//   group('Submit', () {
//     testWidgets('submits the edited values with the phone in international '
//         'format', (tester) async {
//       when(
//         mockEditUseCase.call(any),
//       ).thenAnswer((_) => Completer<BaseResponse<DriverEntity>>().future);

//       await pumpEditProfileScreen(tester);

//       await tester.enterText(
//         fieldByLabel(AppStrings.firstName.tr()),
//         'Mohamed',
//       );
//       await tester.pump();

//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump();

//       final captured =
//           verify(mockEditUseCase.call(captureAny)).captured.single
//               as EditProfileRequest;
//       expect(captured.firstName, 'Mohamed');
//       expect(captured.lastName, 'Ali');
//       expect(captured.email, 'ahmed@test.com');
//       expect(captured.phone, '+201030313971');
//     });
//   });
// }
