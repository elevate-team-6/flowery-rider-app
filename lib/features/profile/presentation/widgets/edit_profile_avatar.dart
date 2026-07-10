import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../view_model/edit_profile_view_model/edit_profile_cubit.dart';
import '../view_model/edit_profile_view_model/edit_profile_states.dart';
import 'profile_avatar.dart';

class EditProfileAvatar extends StatelessWidget {
  final String? fallbackPhotoUrl;
  final VoidCallback onPickPhoto;

  const EditProfileAvatar({
    super.key,
    required this.fallbackPhotoUrl,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<EditProfileCubit, EditProfileStates>(
        buildWhen: (previous, current) => previous.driver != current.driver,
        builder: (context, state) {
          final photoUrl = state.driver?.photo ?? fallbackPhotoUrl;
          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              ProfileAvatar(photoUrl: photoUrl, radius: 44.r),
              InkWell(
                onTap: onPickPhoto,
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 14.r,
                  backgroundColor: AppColors.black,
                  child: Icon(
                    Icons.camera_alt,
                    size: 16.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
