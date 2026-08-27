import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/widgets/faith_mascot.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import '../app_tab.dart';

/// The floating bar the signed-in app navigates from.
///
/// The middle tab is raised and carries the mascot — it is the action the whole
/// product is about, so it does not look like the other four.
class FaithNavBar extends StatelessWidget {
  const FaithNavBar({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// Height of the bar itself; screens add this plus the inset to their
  /// bottom padding so content scrolls clear of it.
  static const double height = 74;

  /// What a tab screen should leave free at the bottom.
  static const double contentInset = height + 14 + 16;

  final AppTab selected;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(28)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            for (final tab in AppTab.values)
              Expanded(
                child: tab.isFeature
                    ? _FeatureTab(tab: tab, onPressed: () => onSelect(tab))
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
    final color = isSelected ? AppColors.accentText : AppColors.textFaint;

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, -22),
            child: Container(
              width: 52,
              height: 52,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.canvas, width: 5),
                boxShadow: AppShadows.card,
              ),
              child: const FittedBox(
                fit: BoxFit.cover,
                child: Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: FaithMascot(),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: Text(
              tab.label,
              style: AppTypography.figtree(
                size: 10.5,
                weight: 800,
                color: AppColors.accentText,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
