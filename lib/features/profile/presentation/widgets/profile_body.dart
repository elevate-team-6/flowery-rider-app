import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/language_bottom_sheet.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/notifications_badge.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    _uiEventSubscription = context.read<ProfileCubit>().eventStream.listen(
      handleUiEvent,
    );
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
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            ProfileTile(
              // leading: ClipOval(
              //   child: Image.network(
              //     '',
              //     width: 48,
              //     height: 48,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              onTap: () {
                // Navigator.pushNamed(context, AppRoutes.editProfile);
              },
              child: Column(children: [Text('kff'), Text('kff'), Text('kff')]),
            ),
            const SizedBox(height: 20),

            ProfileTile(
              onTap: () {
                // Navigator.pushNamed(context, AppRoutes.editProfile);
              },
              child: Column(children: [Text('kff'), Text('kff'), Text('kff')]),
            ),

            const SizedBox(height: 10),
            ProfileMenuItem(
              title: AppStrings.language.tr(),
              leading: SvgPicture.asset(
                AppIcons.language,
                width: 24,
                height: 24,
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
              leading: SvgPicture.asset(AppIcons.logout, width: 24, height: 24),

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
      ),
    );
  }
}
