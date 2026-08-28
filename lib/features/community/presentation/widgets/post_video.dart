import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/theme/app_palette.dart';

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
    final controller = VideoPlayerController.asset(widget.assetPath);
    try {
      await controller.initialize();
    } catch (_) {
      // No decoder, no plugin, or no video surface — the placeholder stands in.
      await controller.dispose();
      return;
    }
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
          : FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
    );
  }
}
