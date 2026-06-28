import 'dart:convert';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_keys.dart';
import '../../../../../core/utils/app_routes.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../config/cache/hive_helper.dart';
import '../../../../config/di/di.dart';
import '../../../../config/services/auth_service.dart';
import '../../../tracking/domain/entities/order_entity.dart';
import '../../../tracking/presentation/screens/order_details_screen.dart';
import '../widgets/petals_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _petalsController;
  late AnimationController _bikeController;
  late AnimationController _wheelController;
  late AnimationController _textController;
  late AnimationController _subtitleController;

  late Animation<Offset> _bikeSlideAnimation;
  late Animation<double> _wheelRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;

  final List<PetalData> _petals = [];

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    _setupPetals();
    _setupAnimations();
    _startAnimations();
    _navigateToNext();
  }

  void _setupPetals() {
    final random = math.Random();
    final List<Color> petalColors = [
      AppColors.pink20, // soft pink
      AppColors.pink30, // rose
      AppColors.pink10, // white-ish pink
    ];

    for (int i = 0; i < 18; i++) {
      _petals.add(
        PetalData(
          size: 8.0 + random.nextDouble() * 10.0,
          speed: 1.0 + random.nextDouble() * 1.5,
          drift: 20.0 + random.nextDouble() * 40.0,
          rotation: random.nextDouble() * math.pi * 2,
          startDelay: random.nextDouble(),
          color: petalColors[random.nextInt(petalColors.length)],
          horizontalOffset: random.nextDouble(),
        ),
      );
    }
  }

  void _setupAnimations() {
    // Petals continuous animation
    _petalsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Wheel rotation (continuous)
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _wheelRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_wheelController);

    // Bike slides in from LEFT
    _bikeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bikeSlideAnimation =
        Tween<Offset>(begin: const Offset(-2.0, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _bikeController, curve: Curves.easeOutCubic),
        );

    // Text fade + slide up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_textController);
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Subtitle fade
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _subtitleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_subtitleController);
  }

  void _startAnimations() {
    _petalsController.repeat();
    _wheelController.repeat();

    // Delay bike start slightly so user can see the full slide from the left
    // after the Native Splash disappears completely.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bikeController.forward();
    });

    // Show text after bike finishes sliding (400ms delay + 900ms animation = 1300ms)
    Future.delayed(const Duration(milliseconds: 1350), () {
      if (mounted) _textController.forward();
    });

    // Show subtitle shortly after the main text starts appearing
    Future.delayed(const Duration(milliseconds: 1750), () {
      if (mounted) _subtitleController.forward();
    });
  }

  void _navigateToNext() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    OrderEntity? cachedOrder;
    int? cachedStep;

    if (isLoggedIn) {
      final hiveHelper = getIt<HiveHelper>();
      final String? cachedJson = await hiveHelper.getData(
        boxName: AppKeys.activeOrderBox,
        key: AppKeys.activeOrderKey,
      );
      if (cachedJson != null) {
        final Map<String, dynamic> data = jsonDecode(cachedJson);
        cachedOrder = OrderEntity.fromJson(data[AppKeys.order]);
        cachedStep = data[AppKeys.uiStep];
      }
    }

    await Future.delayed(const Duration(milliseconds: 4000));
    if (mounted) {
      if (cachedOrder != null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.orderDetails,
          arguments: OrderDetailsArgs(
            order: cachedOrder,
            initialStep: cachedStep,
          ),
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          isLoggedIn ? AppRoutes.mainLayout : AppRoutes.onboarding,
        );
      }
    }
  }

  @override
  void dispose() {
    _petalsController.dispose();
    _bikeController.dispose();
    _wheelController.dispose();
    _textController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.white50, AppColors.lightPink],
          ),
        ),
        child: Stack(
          children: [
            // Layer 1: Wind-blown petals (RIGHT to LEFT)
            CustomPaint(
              painter: PetalsPainter(
                animation: _petalsController,
                petals: _petals,
              ),
              size: Size.infinite,
            ),

            // Layer 2: Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SCOOTER with slide + flower wheel rotation
                  SlideTransition(
                    position: _bikeSlideAnimation,
                    child: SizedBox(
                      width: 320.w,
                      height: 200.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Scooter body image (static)
                          Image.asset(
                            AppImages.scooterBody,
                            width: 320.w,
                            height: 200.h,
                            fit: BoxFit.contain,
                          ),

                          // Flower wheel (rotating, positioned at front/right of scooter)
                          Positioned(
                            right: 80.w,
                            bottom: 40.h,
                            child: RotationTransition(
                              turns: _wheelRotationAnimation,
                              child: Image.asset(
                                AppImages.flowerWheel,
                                width: 72.r,
                                height: 72.r,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // App name
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: Text(
                        AppStrings.floweryRider,
                        style: AppTextStyles.primary38700Playfair,
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Subtitle
                  FadeTransition(
                    opacity: _subtitleFadeAnimation,
                    child: Text(
                      AppStrings.splashSubtitle.tr(),
                      style: AppTextStyles.gray14400PoppinsSpacing,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
