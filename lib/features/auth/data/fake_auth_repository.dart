import '../../../core/errors/result.dart';
import '../domain/auth_repository.dart';
import '../domain/local_session.dart';

/// Lets any valid form in, with a token that only this device recognises —
/// the stand-in until the API issues real ones.
final class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository();

  static const AuthSession _local = AuthSession(accessToken: localSessionToken);

  @override
  Future<Result<AuthSession>> signIn({
    required String identifier,
    required String password,
  }) async => const Success(_local);

  @override
  Future<Result<AuthSession>> register(Registration registration) async =>
      const Success(_local);

  @override
  Future<Result<void>> signOut() async => const Success<void>(null);
}
