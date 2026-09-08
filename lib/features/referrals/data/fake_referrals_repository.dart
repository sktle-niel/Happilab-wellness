import '../../../core/errors/result.dart';
import '../domain/referral.dart';
import '../domain/referrals_repository.dart';

/// The bundled ledger, until the API has a real one.
final class FakeReferralsRepository implements ReferralsRepository {
  const FakeReferralsRepository();

  @override
  Future<Result<List<Referral>>> list() async =>
      const Success(Referral.placeholder);
}
