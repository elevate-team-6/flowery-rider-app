import 'package:cached_network_image/cached_network_image.dart';
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
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _placeholder(),
                placeholder: (context, url) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() =>
      Icon(Icons.person, size: radius, color: AppColors.white80);
}
