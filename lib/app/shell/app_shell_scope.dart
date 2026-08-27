import 'package:flutter/widgets.dart';

import 'app_tab.dart';

/// Lets a screen inside the shell change tabs.
///
/// Screens reach for [openTab] rather than pushing: a tap on "Cash out" should
/// move to the Rewards tab, not stack a second copy of it on top of Home.
class AppShellScope extends InheritedWidget {
  const AppShellScope({
    required this.selectedTab,
    required this.onSelect,
    required super.child,
    super.key,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onSelect;

  static AppShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>();

  /// True when the caller is being shown as a tab rather than pushed on top of
  /// one — which decides whether it needs a back button.
  static bool contains(BuildContext context) => maybeOf(context) != null;

  /// Switches to [tab] when the caller is inside the shell. Returns false when
  /// it is not, so the caller can fall back to pushing a route.
  static bool open(BuildContext context, AppTab tab) {
    final scope = maybeOf(context);
    if (scope == null) return false;
    scope.onSelect(tab);
    return true;
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) =>
      selectedTab != oldWidget.selectedTab;
}
