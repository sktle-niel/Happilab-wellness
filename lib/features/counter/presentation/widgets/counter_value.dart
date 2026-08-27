import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/gap.dart';

/// Presentational only: it is handed a value and a callback, and owns no state.
/// That keeps it `const`-constructible and trivial to preview or test.
class CounterValue extends StatelessWidget {
  const CounterValue({required this.value, this.onReset, super.key});

  final int value;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Taps so far', style: theme.textTheme.titleMedium),
        const Gap.sm(),
        Text('$value', style: theme.textTheme.displaySmall),
        const Gap.lg(),
        AppButton.secondary(
          label: 'Reset',
          icon: Icons.restart_alt,
          onPressed: onReset,
        ),
      ],
    );
  }
}
