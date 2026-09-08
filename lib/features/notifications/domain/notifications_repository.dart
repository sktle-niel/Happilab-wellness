import '../../../core/errors/result.dart';
import 'app_notification.dart';

/// What the brand has told this member, and the reading of it.
abstract interface class NotificationsRepository {
  Future<Result<List<AppNotification>>> list();

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead();
}
