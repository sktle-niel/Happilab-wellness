import '../../core/errors/result.dart';
import '../domain/member_repository.dart';
import '../domain/member_summary.dart';

/// The bundled member, until the API has a real one.
final class FakeMemberRepository implements MemberRepository {
  const FakeMemberRepository();

  @override
  Future<Result<MemberSummary>> summary() async =>
      Success(MemberSummary.placeholder);
}
