import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../shared/utils/video_clips.dart';
import '../../../../shared/widgets/faith_wordmark.dart';
import '../../../../shared/widgets/video_cover.dart';

/// What the onboarding pitch sits on top of: the brand clips, one stage at a
/// time.
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
    'assets/video/onboarding-coffee.mp4',
  ];

  /// One stage per clip — what the progress pips count.
  static int get count => clips.length;

  final int stageIndex;

  /// Fires when the stage's clip reaches its end, so the screen can advance.
  final VoidCallback onClipFinished;

  @override
  State<OnboardingBackdrop> createState() => _OnboardingBackdropState();
}

class _OnboardingBackdropState extends State<OnboardingBackdrop> {
  /// How long a stage takes to cross-fade in — and how long the name over it
  /// takes to change colour with it, so the two land together.
  static const Duration _stageFade = Duration(milliseconds: 600);

  /// How long before the last clip ends the name starts returning to the brand
  /// green. Only the last clip has an outro; the others hand straight over.
  static const Duration _outro = Duration(milliseconds: 1400);

  VideoPlayerController? _controller;

  /// Which clip the current controller belongs to; null before the first load.
  int? _loadedClip;
  bool _hasReportedEnd = false;

  /// True once the last clip is inside its closing [_outro].
  bool _isOutro = false;

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
    final index = widget.stageIndex;
    if (index == _loadedClip) return;

    final previous = _controller;
    previous?.removeListener(_onPlaybackTick);
    _loadedClip = index;
    _hasReportedEnd = false;
    _isOutro = false;
    // Guarded: the first sync runs from initState, where there is nothing to
    // clear and setState is not allowed yet.
    if (previous != null) setState(() => _controller = null);
    await previous?.dispose();

    // An unplayable clip comes back null: the bare canvas stays up and the
    // screen's own timeout moves the sequence along.
    final controller = await initializeAssetClip(
      OnboardingBackdrop.clips[index],
    );
    if (controller == null) return;

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
    if (controller == null) return;

    final outro = _isClosing(controller);
    if (outro != _isOutro) setState(() => _isOutro = outro);

    if (_hasReportedEnd || !controller.value.isCompleted) return;
    _hasReportedEnd = true;
    widget.onClipFinished();
  }

  /// Whether the last clip has reached its closing stretch. Only the last one
  /// closes — the others are followed by another clip, so there is nothing to
  /// wind down for.
  bool _isClosing(VideoPlayerController controller) {
    if (widget.stageIndex != OnboardingBackdrop.count - 1) return false;

    final playback = controller.value;
    if (playback.duration == Duration.zero) return false;
    return playback.duration - playback.position <= _outro;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: context.palette.canvas),
        AnimatedSwitcher(
          duration: _stageFade,
          // AnimatedSwitcher sizes to its child, so the stage has to claim the
          // whole stack itself or its content letterboxes inside it.
          child: SizedBox.expand(
            key: ValueKey(controller == null ? 'loading' : 'clip-$_loadedClip'),
            child: controller == null
                // Nothing to draw yet: the canvas behind this already fills
                // the screen, and the copy on top stays readable on it.
                ? const SizedBox.shrink()
                : VideoCover(controller: controller),
          ),
        ),
        const _ReadabilityScrim(),
        IgnorePointer(
          child: _BrandName(
            // Green whenever there is no footage under it to read against, and
            // again through the last clip's outro.
            inBrandColour: controller == null || _isOutro,
            fade: _stageFade,
          ),
        ),
      ],
    );
  }
}

/// The name, held over every clip for the whole of onboarding.
///
/// Its colour follows what is behind it. A clip takes a moment to open, and
/// until it does the backdrop is the cream canvas — white on cream is nothing
/// at all — so the name wears the brand green there and crosses to white as
/// footage arrives under it. It crosses back for the last clip's outro, which
/// hands the sequence to the green canvas again.
class _BrandName extends StatefulWidget {
  const _BrandName({required this.inBrandColour, required this.fade});

  /// True when the name should be green rather than white.
  final bool inBrandColour;

  /// Matched to the stage's own cross-fade so the two move together.
  final Duration fade;

  @override
  State<_BrandName> createState() => _BrandNameState();
}

class _BrandNameState extends State<_BrandName>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppDuration.entrance,
  )..forward();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final green = context.palette.accentText;

    return Align(
      alignment: const Alignment(0, -0.55),
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          begin: green,
          end: widget.inBrandColour ? green : Colors.white,
        ),
        duration: widget.fade,
        // Linear would clip in and out of the change; easing lets the colour
        // leave and arrive quietly.
        curve: Curves.easeInOut,
        builder: (context, color, _) => FaithWordmark(
          entrance: _entrance,
          showTagline: false,
          scale: 0.9,
          color: color,
        ),
      ),
    );
  }
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
        colors: [Color(0x0D000000), Color(0xD1000000), Color(0xEB000000)],
        stops: [0.3, 0.78, 1],
      ),
    ),
    child: SizedBox.expand(),
  );
}
