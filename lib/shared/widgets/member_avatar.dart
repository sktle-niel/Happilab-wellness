import 'dart:async';

import 'package:flutter/widgets.dart';

import '../domain/profile_photo.dart';
import 'avatar_circle.dart';

/// The signed-in member's avatar, wherever it appears: it follows the profile
/// picture as it changes, and falls back to their initials.
///
/// Stateful only to ask for the kept picture once it is on screen — the first
/// avatar to appear is what triggers the read.
class MemberAvatar extends StatefulWidget {
  const MemberAvatar({
    required this.photo,
    required this.name,
    this.size = 44,
    this.bordered = false,
    super.key,
  });

  final ProfilePhoto photo;
  final String name;
  final double size;
  final bool bordered;

  @override
  State<MemberAvatar> createState() => _MemberAvatarState();
}

class _MemberAvatarState extends State<MemberAvatar> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.photo.load());
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.photo,
    builder: (context, _) => AvatarCircle(
      name: widget.name,
      photo: widget.photo.file,
      size: widget.size,
      bordered: widget.bordered,
    ),
  );
}
