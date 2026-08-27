import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/brand_mark.dart';
import '../../../../shared/widgets/faith_wordmark.dart';
import '../../../../shared/widgets/floating_petals.dart';

/// What the onboarding pitch sits on top of: the brand cover, then the brand
/// clips, one stage at a time.
///
/// Only the stage on screen holds a decoder. Keeping every clip initialised
/// would pin several video surfaces in memory for a screen the user passes
/// through in seconds.
class OnboardingBackdrop extends StatefulWidget {
  const OnboardingBackdrop({
    required this.stageIndex,
    required this.onClipFinished,
    super.key,
  });

  /// Brand clips, in the order the design plays them.
  static const List<String> clips = [
    'assets/video/onboarding-lotion.mp4',
    'assets/video/onboarding-routine.mp4',
  ];

  /// The cover plus one stage per clip — what the progress pips count.
  static int get count => clips.length + 1;

  final int stageIndex;

  /// Fires when the stage's clip reaches its end, so the screen can advance.
  final VoidCallback onClipFinished;

  @override
  State<OnboardingBackdrop> createState() => _OnboardingBackdropState();
}

class _OnboardingBackdropState extends State<OnboardingBackdrop> {
  VideoPlayerController? _controller;

  /// Which clip the current controller belongs to; null on the cover stage.
  int? _loadedClip;
  bool _hasReportedEnd = false;

  int? get _clipIndex => widget.stageIndex == 0 ? null : widget.stageIndex - 1;

  @override
  void initState() {
    super.initState();
    _syncClip();
  }

  @override
  void didUpdateWidget(OnboardingBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stageIndex != widget.stageIndex) _syncClip();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlaybackTick);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _syncClip() async {
    final index = _clipIndex;
    if (index == _loadedClip) return;

    final previous = _controller;
    previous?.removeListener(_onPlaybackTick);
    _loadedClip = index;
    _hasReportedEnd = false;
    // Guarded: the first sync runs from initState, where there is nothing to
    // clear and setState is not allowed yet.
    if (previous != null) setState(() => _controller = null);
    await previous?.dispose();

    if (index == null) return;

    final controller = VideoPlayerController.asset(
      OnboardingBackdrop.clips[index],
    );
    try {
      await controller.initialize();
    } catch (_) {
      // Deliberately broad: a missing decoder throws PlatformException, an
      // absent plugin throws MissingPluginException, and a host without a
      // video surface at all throws UnimplementedError. None of them should
      // strand onboarding — the cover stays up and the screen's own timeout
      // moves the sequence along.
      await controller.dispose();
      return;
    }

    // The stage may have moved on while the clip was loading.
    if (!mounted || _loadedClip != index) {
      await controller.dispose();
      return;
    }

    await controller.setVolume(0);
    controller.addListener(_onPlaybackTick);
    await controller.play();
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  void _onPlaybackTick() {
    final controller = _controller;
    if (_hasReportedEnd || controller == null) return;
    if (!controller.value.isCompleted) return;
    _hasReportedEnd = true;
    widget.onClipFinished();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.canvas),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          // AnimatedSwitcher sizes to its child, so the stage has to claim the
          // whole stack itself or its content letterboxes inside it.
          child: SizedBox.expand(
            key: ValueKey(controller == null ? 'cover' : 'clip-$_loadedClip'),
            child: controller == null
                ? const _BrandCover()
                : _ClipStage(controller: controller),
          ),
        ),
        const _ReadabilityScrim(),
      ],
    );
  }
}

/// Fills the screen with the clip, cropping rather than letterboxing.
class _ClipStage extends StatelessWidget {
  const _ClipStage({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    ),
  );
}

/// The cream cover: petals, mark and wordmark, held high so the copy below has
/// room.
class _BrandCover extends StatelessWidget {
  const _BrandCover();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.canvas,
    child: Stack(
      children: [
        Positioned.fill(child: FloatingPetals()),
        Align(
          alignment: Alignment(0, -0.55),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandMark(size: 150),
              SizedBox(height: 5),
              FaithWordmark(showTagline: false, scale: 0.87),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Darkens the lower half so white copy stays legible over any footage.
class _ReadabilityScrim extends StatelessWidget {
  const _ReadabilityScrim();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x0D1E1408), Color(0xD11E1408), Color(0xEB1E1408)],
        stops: [0.3, 0.78, 1],
      ),
    ),
    child: SizedBox.expand(),
  );
}
