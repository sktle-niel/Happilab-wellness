import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// Fades a child in while it rises into place, on a slice of a shared parent
/// animation.
///
/// Taking an [Animation] rather than owning a controller is what makes the
/// entrance staggerable: one controller drives the screen, each element claims
/// its own [Interval].
class RiseIn extends StatelessWidget {
  const RiseIn({
    required this.animation,
    required this.child,
    this.begin = 0,
    this.end = 1,
    this.offset = 20,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;

  /// Slice of [animation] this element occupies, as fractions of the whole.
  final double begin;
  final double end;

  /// How far below its resting place the child starts, in logical pixels.
  final double offset;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: AppCurves.entrance),
    );

    // The translate sits outermost on purpose: a transform hit-tests its
    // child wherever it has moved it, but an opacity only inside its own
    // bounds — with the order reversed, a rising button is untappable until
    // it has fully landed. Semantics are kept through the fade for the same
    // reason: what is rising is already there for a screen reader.
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, offset * (1 - curved.value)),
        child: Opacity(
          opacity: curved.value.clamp(0, 1),
          alwaysIncludeSemantics: true,
          child: child,
        ),
      ),
      child: child,
    );
  }
}
