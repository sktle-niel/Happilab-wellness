import '../../../core/errors/result.dart';
import '../domain/app_notification.dart';
import '../domain/notifications_repository.dart';

/// The bundled notifications, remembering what has been read for the
/// session.
final class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository();

  final List<AppNotification> _entries = [...AppNotification.placeholder];

  @override
  Future<Result<List<AppNotification>>> list() async =>
      Success(List.unmodifiable(_entries));

  @override
  Future<Result<void>> markRead(String id) async {
    for (var i = 0; i < _entries.length; i++) {
      if (_entries[i].id == id) _entries[i] = _entries[i].asRead();
    }
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> markAllRead() async {
    for (var i = 0; i < _entries.length; i++) {
      _entries[i] = _entries[i].asRead();
    }
    return const Success<void>(null);
  }
}
