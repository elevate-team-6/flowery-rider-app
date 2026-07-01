import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    this.leading,
    required this.child,
    required this.onTap,
  });

  final Widget? leading;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.white90.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Row(
          children: [
            leading ?? SizedBox(),
            SizedBox(width: 16.w),
            Expanded(child: child),
            IconButton(
              onPressed: onTap,
              icon: Icon(Icons.arrow_forward_ios_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
