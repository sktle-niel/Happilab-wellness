import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// Standard page frame: app bar, safe area and screen padding in one place.
///
/// Screens describe their content, not their chrome — so a change to page
/// padding or app bar behaviour lands in one file instead of every screen.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.padding = AppSpacing.screenPadding,
    super.key,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: title == null
        ? null
        : AppBar(title: Text(title!), actions: actions),
    body: SafeArea(
      child: Padding(padding: padding, child: body),
    ),
    floatingActionButton: floatingActionButton,
  );
}
