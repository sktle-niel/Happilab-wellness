import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/theme/app_palette.dart';

/// A member's clip: it rests on a frame until someone asks for it, then plays
/// with sound.
///
/// The muted loop the feed uses would be wrong here — a story is something a
/// member chooses to watch, so nothing starts on its own and the button says
/// what will happen.
class TestimonialVideo extends StatefulWidget {
  const TestimonialVideo({required this.assetPath, super.key});

  final String assetPath;

  @override
  State<TestimonialVideo> createState() => _TestimonialVideoState();
}

class _TestimonialVideoState extends State<TestimonialVideo> {
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
      // Initialising is enough to render the opening frame; seeking for a
      // prettier one is what a paused clip on Android will not reliably do.
      await controller.initialize();
    } catch (_) {
      // No decoder, no plugin, or no video surface — the placeholder stands in
      // and the card still reads. Same fallback the feed's clips take.
      await controller.dispose();
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  Future<void> _toggle() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return ColoredBox(color: context.palette.tint);

    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      // Only the frame and the button redraw as the clip runs; the header and
      // the footer stacked over it are untouched.
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, _) => Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              // Covering scales the frame past its box on one axis, and a
              // FittedBox does not clip on its own — without this the clip
              // spills over the words underneath it.
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: value.size.width,
                height: value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
            if (!value.isPlaying) const Center(child: PlayBadge()),
          ],
        ),
      ),
    );
  }
}

/// The white disc that marks a clip as something to tap.
class PlayBadge extends StatelessWidget {
  const PlayBadge({this.size = 58, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.palette.surface,
      shape: BoxShape.circle,
      boxShadow: context.palette.shadowCard,
    ),
    child: Padding(
      // The glyph's own bearing sits it left of centre in the disc.
      padding: EdgeInsets.only(left: size * 0.06),
      child: Icon(
        Icons.play_arrow_rounded,
        size: size * 0.5,
        color: context.palette.textPrimary,
      ),
    ),
  );
}
