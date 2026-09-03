import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Fills its box with the clip, cropping rather than letterboxing.
///
/// Covering scales the frame past the box on one axis, and a `FittedBox` does
/// not clip on its own — without the hard edge the footage would spill over
/// whatever sits around it.
class VideoCover extends StatelessWidget {
  const VideoCover({required this.controller, super.key});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.cover,
    clipBehavior: Clip.hardEdge,
    child: SizedBox(
      width: controller.value.size.width,
      height: controller.value.size.height,
      child: VideoPlayer(controller),
    ),
  );
}
