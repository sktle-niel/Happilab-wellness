import '../../core/errors/result.dart';
import 'member_summary.dart';

/// The signed-in member's headline figures, from wherever they live.
abstract interface class MemberRepository {
  Future<Result<MemberSummary>> summary();
}
