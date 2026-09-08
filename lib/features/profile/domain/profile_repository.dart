import '../../../core/errors/result.dart';
import '../../../shared/domain/activity_entry.dart';

/// The account behind the profile: what it has done, and the details and
/// password that guard it.
abstract interface class ProfileRepository {
  Future<Result<List<ActivityEntry>>> activity();

  Future<Result<void>> updateDetails({
    required String fullName,
    required String phone,
  });

  Future<Result<void>> changePassword({
    required String current,
    required String next,
  });
}
