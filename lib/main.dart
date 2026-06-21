import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/cache/hive_helper.dart';
import 'config/di/di.dart';
import 'core/utils/app_constants.dart';
import 'core/utils/app_routes.dart';
import 'core/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  configureDependencies();

  // Initialize Hive
  await getIt<HiveHelper>().init();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale(AppConstants.englishCode),
        Locale(AppConstants.arabicCode),
      ],
      path: AppConstants.translationsPath,
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          title: 'Flowery Rider App',
          theme: AppTheme.mainTheme,
          navigatorKey: AppRoutes.navigatorKey,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
        );
      },
    );
  }
}
