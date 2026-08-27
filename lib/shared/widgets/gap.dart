import 'package:flutter/widgets.dart';

import '../../app/theme/app_tokens.dart';

/// Spacing between widgets, taken from the scale instead of a loose `SizedBox`.
/// Works in both a [Row] and a [Column].
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  const Gap.sm({super.key}) : size = AppSpacing.sm;

  const Gap.md({super.key}) : size = AppSpacing.md;

  const Gap.lg({super.key}) : size = AppSpacing.lg;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
