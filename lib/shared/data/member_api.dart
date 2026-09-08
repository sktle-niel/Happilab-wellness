import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/utils/json_reader.dart';
import '../domain/member_repository.dart';
import '../domain/member_summary.dart';

/// [MemberRepository] over the API. The summary is cached for a minute: home
/// and profile both ask for it, and a balance a minute old is still the
/// balance.
final class MemberApi implements MemberRepository {
  const MemberApi(this._client);

  static const Duration _maxAge = Duration(minutes: 1);

  final ApiClient _client;

  @override
  Future<Result<MemberSummary>> summary() =>
      _client.get(ApiEndpoints.me, parse: parseSummary, maxAge: _maxAge);

  static MemberSummary parseSummary(Object? json) {
    final reader = JsonReader.of(json);
    return MemberSummary(
      name: reader.string('name'),
      referralCode: reader.string('referral_code'),
      joinedOn: reader.dateTime('joined_on'),
      points: reader.integer('points'),
      lifetimePoints: reader.integer('lifetime_points'),
      referredPeople: reader.integer('referred_people'),
      referredBuyers: reader.integer('referred_buyers'),
      unreadNotifications: reader.integer('unread_notifications'),
    );
  }
}
