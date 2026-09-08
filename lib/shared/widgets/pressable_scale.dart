import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// The press feedback used across the design: the target shrinks slightly while
/// held, answering on the press itself rather than on release. Wrapping it once
/// keeps every button and icon button in step.
///
/// A member who asked the system for less motion gets the same feedback with
/// no easing to sit through.
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.onPressed,
    this.scale = 0.97,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_isEnabled || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _setPressed(true),
    onTapUp: (_) => _setPressed(false),
    onTapCancel: () => _setPressed(false),
    onTap: widget.onPressed,
    child: AnimatedScale(
      scale: _isPressed ? widget.scale : 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppDuration.press,
      curve: AppCurves.press,
      child: widget.child,
    ),
  );
}
