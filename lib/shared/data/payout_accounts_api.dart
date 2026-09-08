import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/utils/json_reader.dart';
import '../domain/payout_account.dart';

/// [PayoutAccountsRepository] over the API.
final class PayoutAccountsApi implements PayoutAccountsRepository {
  const PayoutAccountsApi(this._client);

  final ApiClient _client;

  @override
  Future<Result<List<PayoutAccount>>> list() =>
      _client.get(ApiEndpoints.myPayoutAccounts, parse: parseList);

  @override
  Future<Result<void>> save(PayoutAccount account) => _client.put(
    ApiEndpoints.myPayoutAccounts,
    body: {
      'wallet': account.kind.name,
      'account_name': account.accountName,
      'number': account.number,
    },
    parse: (_) {},
  );

  static List<PayoutAccount> parseList(Object? json) => JsonReader.listOf(
    json,
    (item) => PayoutAccount(
      kind: item.enumerated('wallet', PayoutKind.values),
      accountName: item.string('account_name'),
      number: item.string('number'),
    ),
  );
}
