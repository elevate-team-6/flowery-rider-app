import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildArrowButton(
            icon: Icons.arrow_back_ios_new,
            isEnabled: currentPage > 1,
            onTap: () => onPageChanged(currentPage - 1),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(totalPages, (index) {
                  int page = index + 1;
                  bool isSelected = page == currentPage;

                  return GestureDetector(
                    onTap: () => onPageChanged(page),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: Colors.grey, width: 1.w),
                      ),
                      child: Text(
                        page.toString(),
                        style: AppTextStyles.primary14500.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.primary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          _buildArrowButton(
            icon: Icons.arrow_forward_ios,
            isEnabled: currentPage < totalPages,
            onTap: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Icon(
        icon,
        size: 16.w,
        color: isEnabled
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.4),
      ),
    );
  }
}
