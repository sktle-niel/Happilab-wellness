import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import 'member_repository.dart';
import 'member_summary.dart';

/// The signed-in member, observable: every screen that shows their name,
/// code or balance reads it here, so one load serves them all and a refresh
/// reaches them all in the same frame.
///
/// Loaded once per session; a failed load keeps its error for the screen to
/// show and offers a retry. Reset on every session boundary so one member's
/// figures are never shown to the next.
class MemberStore extends ChangeNotifier {
  MemberStore(this._repository);

  final MemberRepository _repository;

  MemberSummary? _summary;
  AppException? _error;
  Future<void>? _loading;

  MemberSummary? get summary => _summary;

  AppException? get error => _error;

  bool get isLoaded => _summary != null;

  /// Reads the member, once — later calls await the same read until it
  /// settles. [refresh] asks again.
  Future<void> load() => _loading ??= _load();

  Future<void> refresh() {
    _loading = null;
    return load();
  }

  Future<void> _load() async {
    _error = null;
    final outcome = await _repository.summary();
    outcome.fold((summary) => _summary = summary, (error) => _error = error);
    if (_error != null) _loading = null;
    notifyListeners();
  }

  void reset() {
    _summary = null;
    _error = null;
    _loading = null;
    notifyListeners();
  }
}
