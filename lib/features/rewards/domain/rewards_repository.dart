import '../../../core/errors/result.dart';
import '../../../shared/domain/payout_account.dart';
import 'cash_out.dart';

/// What the server answers a cash out with.
class CashOutReceipt {
  const CashOutReceipt({required this.reference, required this.points});

  /// The server's id for the request — what a member quotes to support.
  final String reference;
  final int points;
}

/// Cash outs: the ones made, and the making of one.
abstract interface class RewardsRepository {
  Future<Result<List<CashOutRecord>>> history();

  Future<Result<CashOutReceipt>> requestCashOut({
    required int points,
    required PayoutAccount to,
  });
}
