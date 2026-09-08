import 'package:flutter/material.dart';

import '../../core/storage/persisted_flag.dart';

/// The eye beside a balance: open while the figure shows, shut while it is
/// kept hidden. One tap flips it, everywhere the figure appears.
class BalanceEye extends StatelessWidget {
  const BalanceEye({required this.hidden, this.color, super.key});

  /// Sits inline with a label, so it stays small; the icon is the target.
  static const double _size = 32;

  final PersistedFlag hidden;

  /// Defaults to the icon theme's colour.
  final Color? color;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: hidden,
    builder: (context, _) => IconButton(
      onPressed: hidden.toggle,
      tooltip: hidden.value ? 'Show points' : 'Hide points',
      splashRadius: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: _size, height: _size),
      icon: Icon(
        hidden.value
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        size: 19,
        color: color,
      ),
    ),
  );
}
