import 'dart:async';

import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';
import '../logging/app_logger.dart';
import '../security/token_store.dart';

/// A yes-or-no the member has set, kept between launches, observable.
///
/// Backed by one [TokenStore] entry: present as [onValue] for yes, absent
/// for no. A preference is no secret, but that store is the one the app
/// ships, and nothing else has to be added for it. A store that will not
/// take a change costs the member nothing now — the value stands for the
/// session — so the failure is logged, not shown.
class PersistedFlag extends ChangeNotifier {
  PersistedFlag({required this._store, this._logger, this.onValue = 'on'});

  final TokenStore _store;
  final AppLogger? _logger;

  /// What the entry holds when the flag is set.
  final String onValue;

  bool _value = false;
  Future<void>? _restoring;

  bool get value => _value;

  /// Reads the last launch's value back, once — later calls await the same
  /// read.
  Future<void> restore() => _restoring ??= _restore();

  Future<void> _restore() async {
    _apply(await _store.read() == onValue);
  }

  void set(bool value) {
    if (!_apply(value)) return;
    unawaited(_keep(value));
  }

  void toggle() => set(!_value);

  bool _apply(bool value) {
    if (value == _value) return false;
    _value = value;
    notifyListeners();
    return true;
  }

  Future<void> _keep(bool value) async {
    try {
      if (value) {
        await _store.write(onValue);
      } else {
        await _store.clear();
      }
    } on AppException catch (error) {
      _logger?.error('A preference could not be saved', error: error);
    }
  }
}
