import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../shared/utils/video_clips.dart';
import '../../../../shared/widgets/video_cover.dart';

/// A looping, muted clip inside a feed post.
///
/// Feed video is decoration, not content: it starts muted, loops, and falls
/// back to a flat tile rather than an error if the platform cannot play it.
class PostVideo extends StatefulWidget {
  const PostVideo({required this.assetPath, required this.height, super.key});

  final String assetPath;
  final double height;

  @override
  State<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Unplayable clips come back null; the placeholder stands in.
    final controller = await initializeAssetClip(widget.assetPath);
    if (controller == null) return;
    if (!mounted) {
      await controller.dispose();
      return;
    }
    await controller.setVolume(0);
    await controller.setLooping(true);
    await controller.play();
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: controller == null
          ? ColoredBox(color: context.palette.tint)
          : VideoCover(controller: controller),
    );
  }
}
