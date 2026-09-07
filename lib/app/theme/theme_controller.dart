import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../core/security/token_store.dart';

/// Which palette the app is drawn in.
///
/// Light is the default; the member can switch to dark from home. The choice
/// is kept between launches in the same platform-secure store the session
/// uses, under its own key — a preference is no secret, but that store is
/// the one the app ships, and nothing else has to be added for it.
class ThemeController extends ChangeNotifier {
  ThemeController({TokenStore? store, this._logger})
    : _store = store ?? InMemoryTokenStore();

  static const String _darkValue = 'dark';

  final TokenStore _store;
  final AppLogger? _logger;

  ThemeMode _mode = ThemeMode.light;
  Future<void>? _restoring;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  /// Reads the last launch's choice back, once — later calls await the same
  /// read.
  Future<void> restore() => _restoring ??= _restore();

  Future<void> _restore() async {
    final kept = await _store.read();
    _apply(kept == _darkValue ? ThemeMode.dark : ThemeMode.light);
  }

  void setDark(bool enabled) {
    final mode = enabled ? ThemeMode.dark : ThemeMode.light;
    if (!_apply(mode)) return;
    unawaited(_keep(mode));
  }

  bool _apply(ThemeMode mode) {
    if (mode == _mode) return false;
    _mode = mode;
    notifyListeners();
    return true;
  }

  /// Kept for the next launch. A store that will not take it costs the
  /// member nothing now — the choice stands for the session — so the failure
  /// is logged, not shown.
  Future<void> _keep(ThemeMode mode) async {
    try {
      if (mode == ThemeMode.dark) {
        await _store.write(_darkValue);
      } else {
        await _store.clear();
      }
    } on AppException catch (error) {
      _logger?.error('Theme choice could not be saved', error: error);
    }
  }
}
