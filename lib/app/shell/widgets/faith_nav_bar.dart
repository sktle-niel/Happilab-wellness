import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/widgets/faith_mascot.dart';
import '../../theme/app_typography.dart';
import '../app_tab.dart';
import '../../theme/app_palette.dart';

/// The floating bar the signed-in app navigates from.
///
/// The middle tab is raised and carries the mascot — it is the action the whole
/// product is about, so it does not look like the other four. That button is
/// drawn in an unclipped layer above the bar: inside it, the bar's own rounded
/// clip cuts its head off.
class FaithNavBar extends StatelessWidget {
  const FaithNavBar({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  static const double height = 74;

  /// What a tab screen should leave free at the bottom, so its last row is not
  /// stranded under the bar.
  static const double contentInset = height + 14 + 16;

  static const BorderRadius _shape = BorderRadius.all(Radius.circular(28));

  final AppTab selected;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: _shape,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: context.palette.surface.withValues(alpha: 0.95),
                borderRadius: _shape,
                boxShadow: context.palette.shadowCard,
              ),
              child: Row(
                children: [
                  for (final tab in AppTab.values)
                    Expanded(
                      child: tab.isFeature
                          // The raised button sits in the layer above; this
                          // slot only reserves its width.
                          ? const SizedBox.expand()
                          : _NavTab(
                              tab: tab,
                              isSelected: tab == selected,
                              onPressed: () => onSelect(tab),
                            ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Mirrors the bar's slots so the raised button lands over the width
        // its tab reserved, wherever that tab sits in the order.
        Positioned(
          left: 0,
          right: 0,
          top: -20,
          child: Row(
            children: [
              for (final tab in AppTab.values)
                Expanded(
                  child: tab.isFeature
                      ? Center(
                          child: _FeatureTab(
                            tab: tab,
                            onPressed: () => onSelect(tab),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.tab,
    required this.isSelected,
    required this.onPressed,
  });

  final AppTab tab;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? context.palette.accentText
        : context.palette.textFaint;

    return Semantics(
      button: true,
      selected: isSelected,
      label: tab.label,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon, size: 23, color: color),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: AppTypography.figtree(
                size: 10.5,
                weight: 800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The raised centre tab.
class _FeatureTab extends StatelessWidget {
  const _FeatureTab({required this.tab, required this.onPressed});

  final AppTab tab;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: tab.label,
    child: GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: context.palette.accent,
              shape: BoxShape.circle,
              border: Border.all(color: context.palette.canvas, width: 4),
              boxShadow: context.palette.shadowCard,
            ),
            child: const FittedBox(fit: BoxFit.contain, child: FaithMascot()),
          ),
          const SizedBox(height: 2),
          Text(
            tab.label,
            style: AppTypography.figtree(
              size: 10.5,
              weight: 800,
              color: context.palette.accentText,
            ),
          ),
        ],
      ),
    ),
  );
}
