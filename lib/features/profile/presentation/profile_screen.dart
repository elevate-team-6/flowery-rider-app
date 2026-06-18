import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/di/di.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/core/widgets/custom_flower_loading.dart';
import 'package:flowery_rider_app/core/widgets/custom_snack_bar.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/logout_view_model/logout_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/logout_view_model/logout_event.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LogoutCubit>(
      create: (_) => getIt<LogoutCubit>(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  static const Key logoutButtonKey = Key('profile_logout_button');

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  StreamSubscription<BaseUiEvent>? _sideEffectSubscription;

  @override
  void initState() {
    super.initState();
    _sideEffectSubscription = context.read<LogoutCubit>().eventStream.listen(
      _handleSideEffect,
    );
  }

  @override
  void dispose() {
    _sideEffectSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.profile.tr())),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              ListTile(
                key: ProfileView.logoutButtonKey,
                contentPadding: EdgeInsets.zero,
                horizontalTitleGap: 6.w,
                minLeadingWidth: 0,
                leading: const Icon(
                  Icons.logout,
                  color: AppColors.white90,
                  size: 16,
                ),
                title: Text(
                  AppStrings.logout.tr(),
                  style: AppTextStyles.black13400,
                ),
                trailing: const Icon(
                  Icons.logout,
                  color: AppColors.white90,
                  size: 24,
                ),
                onTap: _onLogoutTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLogoutTap() async {
    final confirmed = await LogoutConfirmationDialog.show(context);
    if (confirmed != true) return;
    if (!mounted) return;

    context.read<LogoutCubit>().doIntent(const LogoutEvent());
  }

  void _handleSideEffect(BaseUiEvent event) {
    switch (event) {
      case ShowLoadingEvent():
        LoadingDialog.show(context: context);
      case HideLoadingEvent():
        LoadingDialog.hide(context: context);
      case DisplaySuccessEvent(:final successMessage):
        CustomSnackBar.showSuccessMessage(successMessage);
      case DisplayErrorEvent(:final errorMessage):
        CustomSnackBar.showErrorMessage(errorMessage);
      case NavigateEvent(:final routeName):
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(routeName, (route) => false);
    }
  }
}
