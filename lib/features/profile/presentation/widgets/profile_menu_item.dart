import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_text_styles.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final Widget? leading;
  final Widget trailing;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.title,
    this.titleStyle,
    this.leading,
    this.trailing = const Icon(Icons.arrow_forward_ios, size: 24),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title, style: titleStyle ?? AppTextStyles.black13400),
      trailing: _buildTrailing(),
      onTap: onTap,
    );
  }

  Widget _buildTrailing() {
    if (trailing is Icon) {
      final icon = trailing as Icon;
      return Icon(icon.icon, size: (icon.size ?? 24).r, color: icon.color);
    }
    return trailing;
  }
}
