import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// The falcon animations the app ships.
///
/// Each is a glTF clip baked to a frame sequence by
/// `tool/render_model_frames.mjs`. Flutter has no glTF renderer, and every
/// runtime option for one goes through a WebView — a browser engine, a network
/// permission and seconds of jank. Rendering ahead of time costs a few hundred
/// kilobytes and nothing else.
///
/// Every sequence is a loop followed by an optional tail. What the tail is
/// differs: the mark folds its wings and holds them in, the perch shakes them
/// out and carries straight on. Named for where each is used rather than for
/// the motion — which motion suits a place is a question that keeps being
/// answered again, and the call sites should not move every time it is.
enum FalconClip {
  /// Beating its wings side-on, filling the loader. No tail: a loader that
  /// stops looks like a loader that has died.
  loader('fly', loopFrames: 24, loop: AppDuration.wingbeat),

  /// Head-on and small, on the tab bar. It sways a few beats, folds its wings
  /// and holds them in — a bird that never settled would pull the eye off the
  /// screen it sits on.
  mark(
    'steady',
    loopFrames: 30,
    loop: AppDuration.wingSway,
    loops: 3,
    tailFrames: 14,
    tail: AppDuration.wingFold,
    rest: AppDuration.wingsRested,
    reverses: true,
  ),

  /// On the rewards card, seen head-on: flying, then pulling up to shake its
  /// wings out for a few seconds before carrying on.
  rewards(
    'rewards',
    loopFrames: 30,
    loop: AppDuration.wingSway,
    loops: 3,
    tailFrames: 24,
    tail: AppDuration.wingShake,
    tailLoops: 4,
  );

  const FalconClip(
    this._folder, {
    required this.loopFrames,
    required this.loop,
    this.loops = 1,
    this.tailFrames = 0,
    this.tail = Duration.zero,
    this.tailLoops = 1,
    this.rest = Duration.zero,
    this.reverses = false,
  });

  final String _folder;

  /// Frames of the loop, which the sequence leads with, and how long one turn
  /// of it takes — then how many turns before the tail.
  final int loopFrames;
  final Duration loop;
  final int loops;

  /// Frames of the tail that follows, how long one run of it takes, and how
  /// many runs. Zero frames for a clip that only ever loops.
  final int tailFrames;
  final Duration tail;
  final int tailLoops;

  /// How long the last frame of the tail is held, and whether the tail is then
  /// run backwards to get home. A fold needs both; a shake needs neither,
  /// because it ends where it started.
  final Duration rest;
  final bool reverses;

  int get frameCount => loopFrames + tailFrames;

  FalconCycle get cycle => FalconCycle(this);

  String frameAsset(int frame) =>
      'assets/images/falcon/$_folder/${frame.toString().padLeft(2, '0')}.png';
}

/// Where a clip's cycle stands at a given moment.
///
/// Pure, so the rhythm can be tested without pumping a widget — and the widget
/// is left with nothing to do but draw the frame it is handed.
class FalconCycle {
  const FalconCycle(this.clip);

  final FalconClip clip;

  Duration get total =>
      clip.loop * clip.loops +
      clip.tail * clip.tailLoops +
      clip.rest +
      (clip.reverses ? clip.tail : Duration.zero);

  int frameAt(Duration elapsed) {
    var at = elapsed.inMilliseconds % total.inMilliseconds;

    final turn = clip.loop.inMilliseconds;
    final looping = turn * clip.loops;
    if (at < looping) return (at % turn) * clip.loopFrames ~/ turn;
    at -= looping;

    final running = clip.tail.inMilliseconds;
    final tailing = running * clip.tailLoops;
    if (at < tailing) {
      return clip.loopFrames + _tailStep(at % running, running);
    }
    at -= tailing;

    final last = clip.frameCount - 1;
    if (!clip.reverses || at < clip.rest.inMilliseconds) return last;

    // Coming back out is the tail run backwards.
    return last - _tailStep(at - clip.rest.inMilliseconds, running);
  }

  int _tailStep(int at, int running) =>
      (at * clip.tailFrames ~/ running).clamp(0, clip.tailFrames - 1);
}

/// The falcon, running one of its clips.
class Falcon extends StatefulWidget {
  const Falcon({required this.clip, this.size = 150, super.key});

  final FalconClip clip;
  final double size;

  @override
  State<Falcon> createState() => _FalconState();
}

class _FalconState extends State<Falcon> with SingleTickerProviderStateMixin {
  late final FalconCycle _cycle = widget.clip.cycle;
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: _cycle.total,
  )..repeat();

  bool _isCached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isCached) return;
    _isCached = true;
    // Decode every frame up front. Left to itself the first turn of the loop
    // stutters as each PNG is decoded on the way past.
    for (var frame = 0; frame < widget.clip.frameCount; frame++) {
      precacheImage(AssetImage(widget.clip.frameAsset(frame)), context);
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: widget.size,
    child: AnimatedBuilder(
      animation: _loop,
      builder: (context, _) => Image.asset(
        widget.clip.frameAsset(_cycle.frameAt(_cycle.total * _loop.value)),
        width: widget.size,
        height: widget.size,
        // Holds the frame on screen until the next one is ready, so a slow
        // decode reads as a held pose instead of a blink.
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'A falcon in flight',
      ),
    ),
  );
}
