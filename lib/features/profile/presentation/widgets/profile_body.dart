import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/widgets/custom_flower_loading.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/profile_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/profile_states.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/language_bottom_sheet.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/notifications_badge.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../config/base_ui_handler/ui_event_handler_mixin.dart';
import '../view_model/profile_cubit.dart';
import 'logout_dialog.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> with UiEventHandler {
  StreamSubscription<BaseUiEvent>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    _uiEventSubscription = context.read<ProfileCubit>().eventStream.listen(
      handleUiEvent,
    );
    cubit.doEvent(const GetProfileEvent());
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(AppStrings.profile.tr(), style: AppTextStyles.black20500),
        leading: Icon(Icons.arrow_back_ios_new_outlined),
        actions: [
          NotificationBadge(
            count: '3',
            onTap: () {
              // Navigator.pushNamed(context, AppRoutes.notificationScreen);
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          if (state.profileState.isLoading) {
            return const LoadingDialog();
          }
          final driver = state.profileState.data;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                ProfileTile(
                  leading: ClipOval(
                    child: driver?.photo != null && driver!.photo.isNotEmpty
                        ? Image.network(
                            driver.photo,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person),
                          ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.editProfile,arguments: state.profileState.data);
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${driver?.firstName ?? ''} ${driver?.lastName ?? ''}',
                          style: AppTextStyles.black16500,
                        ),
                        Text(driver?.email ?? ''),
                        Text(driver?.phone ?? ''),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ProfileTile(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.vehicleInfo.tr(),
                        style: AppTextStyles.black18500,
                      ),
                      const SizedBox(height: 4),
                      Text(driver?.vehicleType ?? ''),
                      const SizedBox(height: 4),
                      Text(driver?.vehicleNumber ?? ''),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                ProfileMenuItem(
                  title: AppStrings.language.tr(),
                  leading: SvgPicture.asset(
                    AppIcons.language,
                    width: 24,
                    height: 24,
                  ),
                  trailing: Text(
                    context.locale.languageCode == 'ar'
                        ? AppStrings.arabic.tr()
                        : AppStrings.english.tr(),
                    style: AppTextStyles.primary12400,
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (innerContext) => BlocProvider.value(
                        value: context.read<ProfileCubit>(),
                        child: const LanguageBottomSheet(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                ProfileMenuItem(
                  leading: SvgPicture.asset(
                    AppIcons.logout,
                    width: 24,
                    height: 24,
                  ),

                  title: AppStrings.logout.tr(),
                  trailing: SvgPicture.asset(
                    AppIcons.logout,
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      AppColors.gray,
                      BlendMode.srcIn,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: context.read<ProfileCubit>(),
                        child: const LogoutDialog(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
