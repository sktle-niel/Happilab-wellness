import '../../core/errors/result.dart';
import '../domain/payout_account.dart';

/// Wallets kept for the session, starting with none — the way a new member
/// starts — or with whatever a test seeds.
final class FakePayoutAccountsRepository implements PayoutAccountsRepository {
  FakePayoutAccountsRepository({Iterable<PayoutAccount> initial = const []})
    : _accounts = {for (final account in initial) account.kind: account};

  final Map<PayoutKind, PayoutAccount> _accounts;

  @override
  Future<Result<List<PayoutAccount>>> list() async =>
      Success([for (final kind in PayoutKind.values) ?_accounts[kind]]);

  @override
  Future<Result<void>> save(PayoutAccount account) async {
    _accounts[account.kind] = account;
    return const Success<void>(null);
  }
}
