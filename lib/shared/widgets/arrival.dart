import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'rise_in.dart';

/// Rises its child in once, on its own clock — for something that turns up
/// by itself, like a message arriving, where there is no screen entrance to
/// ride. Key the child to what arrived, so a list that shifts does not
/// replay it on the wrong row.
class Arrival extends StatefulWidget {
  const Arrival({required this.child, this.offset = 12, super.key});

  final Widget child;

  /// How far below its resting place the child starts.
  final double offset;

  @override
  State<Arrival> createState() => _ArrivalState();
}

class _ArrivalState extends State<Arrival> with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppDuration.arrival,
  )..forward();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RiseIn(animation: _entrance, offset: widget.offset, child: widget.child);
}
