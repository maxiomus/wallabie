import 'package:flutter/material.dart';

const _avatarSize = 48.0;

/// A circular avatar widget that displays a user's profile photo.
///
/// Shows a person icon placeholder when no photo URL is provided.
class Avatar extends StatelessWidget {
  /// Creates an [Avatar] with an optional photo URL.
  const Avatar({super.key, this.photo});

  /// URL of the profile photo, or null to show placeholder.
  final String? photo;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    return CircleAvatar(
      radius: _avatarSize,
      backgroundImage: photo != null ? NetworkImage(photo) : null,
      child: photo == null
          ? const Icon(Icons.person_outline, size: _avatarSize)
          : null,
    );
  }
}