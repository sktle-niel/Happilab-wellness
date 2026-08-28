import 'package:flutter/material.dart';

/// Which palette the app is drawn in.
///
/// Light is the default; the member can switch to dark from their profile.
/// The choice lives for the session — persisting it needs a preference store
/// the app does not ship yet.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void setDark(bool enabled) {
    final mode = enabled ? ThemeMode.dark : ThemeMode.light;
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }
}
