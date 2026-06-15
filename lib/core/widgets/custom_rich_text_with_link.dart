import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomRichTextWithLink extends StatelessWidget {
  final String normalText;
  final String linkText;
  final VoidCallback onLinkTap;
  final TextAlign? textAlign;
  final Color? linkTextColor;

  const CustomRichTextWithLink({
    super.key,
    required this.normalText,
    required this.linkText,
    required this.onLinkTap,
    this.textAlign,
    this.linkTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign ?? TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(text: normalText, style: AppTextStyles.black16400),
          TextSpan(
            text: linkText,
            style: AppTextStyles.black16400.copyWith(
              color: linkTextColor,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onLinkTap,
          ),
        ],
      ),
    );
  }
}
