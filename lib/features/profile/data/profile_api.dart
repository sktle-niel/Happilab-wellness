import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/json_reader.dart';
import '../../../shared/domain/activity_entry.dart';
import '../domain/profile_repository.dart';

/// [ProfileRepository] over the API.
final class ProfileApi implements ProfileRepository {
  const ProfileApi(this._client);

  final ApiClient _client;

  @override
  Future<Result<List<ActivityEntry>>> activity() =>
      _client.get(ApiEndpoints.myActivity, parse: parseActivity);

  @override
  Future<Result<void>> updateDetails({
    required String fullName,
    required String phone,
  }) => _client.put(
    ApiEndpoints.myDetails,
    body: {'full_name': fullName, 'phone': phone},
    parse: (_) {},
  );

  @override
  Future<Result<void>> changePassword({
    required String current,
    required String next,
  }) => _client.put(
    ApiEndpoints.myPassword,
    body: {'current_password': current, 'new_password': next},
    parse: (_) {},
  );

  static List<ActivityEntry> parseActivity(Object? json) => JsonReader.listOf(
    json,
    (item) => ActivityEntry(
      title: item.string('title'),
      when: item.string('when'),
      kind: item.enumerated('kind', ActivityKind.values),
      points: item.optionalInteger('points'),
    ),
  );
}
