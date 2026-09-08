import '../../../core/errors/result.dart';
import 'referral.dart';

/// The people this member brought in, newest first.
abstract interface class ReferralsRepository {
  Future<Result<List<Referral>>> list();
}
