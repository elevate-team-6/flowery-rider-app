import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

/// Circular avatar that loads the driver photo from the network and
/// gracefully falls back to a person icon while loading or on error.
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;

  const ProfileAvatar({super.key, required this.photoUrl, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.gray10,
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() =>
      Icon(Icons.person, size: radius, color: AppColors.white80);
}
