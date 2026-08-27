import 'package:flutter/widgets.dart';

import 'app_dependencies.dart';

/// Exposes [AppDependencies] to the widget tree.
///
/// Widgets read their services from `AppScope.of(context)` instead of importing
/// a global, which keeps every screen testable in isolation.
class AppScope extends InheritedWidget {
  const AppScope({required this.dependencies, required super.child, super.key});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found above this widget.');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}
