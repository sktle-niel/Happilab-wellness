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
/// Every sequence is a seamless loop of the bird's flight. Named for where
/// each is used rather than for the motion — which motion suits a place is a
/// question that keeps being answered again, and the call sites should not
/// move every time it is.
enum FalconClip {
  /// Beating its wings side-on, filling the loader. A loader that stops
  /// looks like a loader that has died.
  loader('fly', frameCount: 24, loop: AppDuration.wingbeat),

  /// Head-on and small, on the tab bar, riding the same flight at an
  /// unhurried sway. It stays airborne on purpose: the HD model's resting
  /// pose drapes the wings forward, which reads as a tangle at mark size.
  mark('steady', frameCount: 30, loop: AppDuration.wingSway);

  const FalconClip(
    this._folder, {
    required this.frameCount,
    required this.loop,
  });

  final String _folder;

  /// Frames the loop was baked to, and how long one turn of it takes.
  final int frameCount;
  final Duration loop;

  FalconCycle get cycle => FalconCycle(this);

  String frameAsset(int frame) =>
      'assets/images/falcon/$_folder/${frame.toString().padLeft(2, '0')}.png';
}

/// Where a clip's loop stands at a given moment.
///
/// Pure, so the rhythm can be tested without pumping a widget — and the widget
/// is left with nothing to do but draw the frame it is handed.
class FalconCycle {
  const FalconCycle(this.clip);

  final FalconClip clip;

  Duration get total => clip.loop;

  int frameAt(Duration elapsed) {
    final at = elapsed.inMilliseconds % total.inMilliseconds;
    return at * clip.frameCount ~/ total.inMilliseconds;
  }
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
