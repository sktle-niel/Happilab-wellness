import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/app_notification.dart';
import '../domain/notifications_repository.dart';

/// The member's notifications, and the reading of them.
///
/// Reads mark the list here first and are written through: the tile should
/// not wait on the network to change, and a write that fails leaves nothing
/// worse than an unread dot coming back next time.
class NotificationsController extends ChangeNotifier {
  NotificationsController(this._repository);

  final NotificationsRepository _repository;

  List<AppNotification> _entries = const [];
  AppException? _error;
  bool _isLoading = true;

  List<AppNotification> get entries => _entries;
  AppException? get error => _error;
  bool get isLoading => _isLoading;

  bool get hasUnread => _entries.any((entry) => entry.isUnread);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final outcome = await _repository.list();
    outcome.fold((entries) => _entries = entries, (error) => _error = error);
    _isLoading = false;
    notifyListeners();
  }

  void markAllRead() {
    _entries = [for (final entry in _entries) entry.asRead()];
    notifyListeners();
    unawaited(_repository.markAllRead());
  }

  /// Reading one is opening it: it is marked read, and its destination is
  /// handed back for the screen to go to. One with nowhere to point answers
  /// null and is left alone.
  NotificationDestination? open(AppNotification notification) {
    final destination = notification.destination;
    if (destination == null) return null;
    _entries = [
      for (final entry in _entries)
        if (identical(entry, notification)) entry.asRead() else entry,
    ];
    notifyListeners();
    unawaited(_repository.markRead(notification.id));
    return destination;
  }
}
