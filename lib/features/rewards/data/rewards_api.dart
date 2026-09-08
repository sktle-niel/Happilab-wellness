import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/json_reader.dart';
import '../../../shared/domain/payout_account.dart';
import '../domain/cash_out.dart';
import '../domain/rewards_repository.dart';

/// [RewardsRepository] over the API.
final class RewardsApi implements RewardsRepository {
  const RewardsApi(this._client);

  final ApiClient _client;

  @override
  Future<Result<List<CashOutRecord>>> history() =>
      _client.get(ApiEndpoints.myCashOuts, parse: parseHistory);

  @override
  Future<Result<CashOutReceipt>> requestCashOut({
    required int points,
    required PayoutAccount to,
  }) => _client.post(
    ApiEndpoints.myCashOuts,
    body: {'points': points, 'wallet': to.kind.name, 'number': to.number},
    parse: parseReceipt,
  );

  static List<CashOutRecord> parseHistory(Object? json) => JsonReader.listOf(
    json,
    (item) => CashOutRecord(
      destination: item.string('destination'),
      when: item.string('when'),
      points: item.integer('points'),
    ),
  );

  static CashOutReceipt parseReceipt(Object? json) {
    final reader = JsonReader.of(json);
    return CashOutReceipt(
      reference: reader.string('reference'),
      points: reader.integer('points'),
    );
  }
}
