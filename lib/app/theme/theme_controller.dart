import 'package:flutter/material.dart';

import '../../core/logging/app_logger.dart';
import '../../core/security/token_store.dart';
import '../../core/storage/persisted_flag.dart';

/// Which palette the app is drawn in.
///
/// Light is the default; the member can switch to dark from home, and the
/// choice is kept between launches as a [PersistedFlag].
class ThemeController extends ChangeNotifier {
  ThemeController({TokenStore? store, AppLogger? logger})
    : _dark = PersistedFlag(
        store: store ?? InMemoryTokenStore(),
        logger: logger,
        onValue: 'dark',
      ) {
    _dark.addListener(notifyListeners);
  }

  final PersistedFlag _dark;

  ThemeMode get mode => _dark.value ? ThemeMode.dark : ThemeMode.light;

  bool get isDark => _dark.value;

  /// Reads the last launch's choice back, once.
  Future<void> restore() => _dark.restore();

  void setDark(bool enabled) => _dark.set(enabled);

  @override
  void dispose() {
    _dark.dispose();
    super.dispose();
  }
}
