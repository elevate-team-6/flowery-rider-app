import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/language_bottom_sheet.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
    'LanguageBottomSheet displays correctly and triggers locale change',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          startLocale: const Locale('en'),
          saveLocale: false,
          useOnlyLangCode: true,
          child: MaterialApp(
            home: Scaffold(
              body: ScreenUtilInit(
                designSize: const Size(375, 812),
                builder: (context, child) => const LanguageBottomSheet(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LanguageBottomSheet), findsOneWidget);

      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_off), findsOneWidget);

      final alternativeLanguageFinder = find.byType(InkWell).first;
      await tester.tap(alternativeLanguageFinder);
      await tester.pumpAndSettle();

      expect(find.byType(LanguageBottomSheet), findsNothing);
    },
  );
}
