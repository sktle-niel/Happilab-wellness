import '../../../core/errors/result.dart';
import '../../../shared/domain/payout_account.dart';
import '../domain/cash_out.dart';
import '../domain/rewards_repository.dart';

/// The bundled history, and cash outs that always go through.
final class FakeRewardsRepository implements RewardsRepository {
  const FakeRewardsRepository();

  @override
  Future<Result<List<CashOutRecord>>> history() async =>
      const Success(CashOutRecord.placeholder);

  @override
  Future<Result<CashOutReceipt>> requestCashOut({
    required int points,
    required PayoutAccount to,
  }) async => Success(CashOutReceipt(reference: 'local', points: points));
}
