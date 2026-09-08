import '../../../core/errors/result.dart';
import '../../../shared/domain/activity_entry.dart';
import '../domain/profile_repository.dart';

/// The bundled activity, and edits that always go through.
final class FakeProfileRepository implements ProfileRepository {
  const FakeProfileRepository();

  @override
  Future<Result<List<ActivityEntry>>> activity() async =>
      const Success(ActivityEntry.placeholder);

  @override
  Future<Result<void>> updateDetails({
    required String fullName,
    required String phone,
  }) async => const Success<void>(null);

  @override
  Future<Result<void>> changePassword({
    required String current,
    required String next,
  }) async => const Success<void>(null);
}
