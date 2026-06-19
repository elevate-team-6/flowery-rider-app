import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_assets.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubmitScreen extends StatelessWidget {
  const SubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Column(
                  children: [
                    Spacer(),

                    SvgPicture.asset(AppIcons.success),

                    SizedBox(height: 24.h),

                    Text(
                      AppStrings.submitSuccess.tr(),
                      style: AppTextStyles.black18600,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      AppStrings.submitDescription.tr(),
                      style: AppTextStyles.gray16400,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24.h),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: Text(AppStrings.login.tr()),
                    ),
                  ],
                ),
              ),
            ),

            SvgPicture.asset(AppIcons.submitIcon),
          ],
        ),
      ),
    );
  }
}
