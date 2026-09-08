import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/json_reader.dart';
import '../domain/app_notification.dart';
import '../domain/notifications_repository.dart';

/// [NotificationsRepository] over the API.
final class NotificationsApi implements NotificationsRepository {
  const NotificationsApi(this._client);

  final ApiClient _client;

  @override
  Future<Result<List<AppNotification>>> list() =>
      _client.get(ApiEndpoints.myNotifications, parse: parseList);

  @override
  Future<Result<void>> markRead(String id) =>
      _client.post(ApiEndpoints.notificationRead(id), parse: (_) {});

  @override
  Future<Result<void>> markAllRead() =>
      _client.post(ApiEndpoints.myNotificationsRead, parse: (_) {});

  static List<AppNotification> parseList(Object? json) =>
      JsonReader.listOf(json, _one);

  static AppNotification _one(JsonReader item) => AppNotification(
    id: item.string('id'),
    body: item.string('body'),
    when: item.string('when'),
    isUnread: item.boolean('is_unread'),
    destination: _destination(item.optionalString('destination')),
  );

  /// A destination the app does not know is news with nowhere to go, not a
  /// broken response: the server may add kinds before the app learns them.
  static NotificationDestination? _destination(String? name) {
    for (final value in NotificationDestination.values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
