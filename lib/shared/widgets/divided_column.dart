import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';

/// Stacks rows with the hairline divider the design puts between list items,
/// and no trailing rule under the last one.
class DividedColumn extends StatelessWidget {
  const DividedColumn({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0)
          SizedBox(
            height: 1,
            child: ColoredBox(color: context.palette.divider),
          ),
        children[index],
      ],
    ],
  );
}
