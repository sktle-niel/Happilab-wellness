import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import 'circle_icon_button.dart';

/// Back button plus title — the top of every screen below the home tab.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    required this.title,
    this.onBack,
    this.trailing,
    super.key,
  });

  final String title;

  /// Defaults to popping the current route.
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleIconButton(
        icon: Icons.arrow_back,
        semanticLabel: 'Back',
        onPressed: onBack ?? Navigator.of(context).pop,
      ),
      const SizedBox(width: AppSpacing.sm + 2),
      Expanded(
        child: Text(
          title,
          style: AppTypography.figtree(
            size: 25,
            weight: 800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      ?trailing,
    ],
  );
}
