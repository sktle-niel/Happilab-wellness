import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';

/// The eye at the end of a password field. Both auth forms carry one, wired
/// to their own controller.
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    required this.isHidden,
    required this.onPressed,
    super.key,
  });

  final bool isHidden;
  final VoidCallback onPressed;

  IconData get _icon =>
      isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined;

  String get _tooltip => isHidden ? 'Show password' : 'Hide password';

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    icon: Icon(_icon, size: 18, color: context.palette.textFaint),
    tooltip: _tooltip,
    splashRadius: 20,
  );
}
