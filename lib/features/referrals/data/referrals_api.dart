import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/json_reader.dart';
import '../domain/referral.dart';
import '../domain/referrals_repository.dart';

/// [ReferralsRepository] over the API.
final class ReferralsApi implements ReferralsRepository {
  const ReferralsApi(this._client);

  final ApiClient _client;

  @override
  Future<Result<List<Referral>>> list() =>
      _client.get(ApiEndpoints.myReferrals, parse: parseList);

  static List<Referral> parseList(Object? json) =>
      JsonReader.listOf(json, _one);

  static Referral _one(JsonReader item) => Referral(
    name: item.string('name'),
    stage: item.enumerated('stage', ReferralStage.values),
    when: item.string('when'),
    pointsEarned: item.integer('points_earned'),
    avatarUrl: item.optionalString('avatar_url'),
  );
}
