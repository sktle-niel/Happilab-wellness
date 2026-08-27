import 'package:flutter/material.dart';

/// A scroll view whose content centres itself while it is shorter than the
/// screen, and scrolls once it is taller.
///
/// A plain [SingleChildScrollView] always pins content to the top, which leaves
/// a short form stranded above a pool of empty space.
class CenteredScrollView extends StatelessWidget {
  const CenteredScrollView({
    required this.children,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ),
  );
}
