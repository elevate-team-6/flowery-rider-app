import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/services/auth_service.dart';
import 'package:flowery_rider_app/core/utils/app_assets.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: height * 0.55,
                width: double.infinity,
                child: Transform.scale(
                  scale: 1.7,
                  child: Lottie.asset(
                    AppLottie.onboardingAnimation,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${AppStrings.welcomeTo.tr()}\n",
                        style: AppTextStyles.black20500,
                      ),
                      TextSpan(
                        text: AppStrings.floweryRiderApp.tr(),
                        style: AppTextStyles.black20500,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      AuthService.setOnboardingCompleted();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                    child: Text(AppStrings.login.tr()),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: () {
                      AuthService.setOnboardingCompleted();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.applyScreen,
                        (route) => false,
                      );
                    },
                    child: Text(
                      AppStrings.applyNow.tr(),
                      style: AppTextStyles.black12600.copyWith(
                        color: AppColors.black40,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                AppStrings.versionPlaceholder.tr(),
                style: AppTextStyles.black12400.copyWith(color: AppColors.gray),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
