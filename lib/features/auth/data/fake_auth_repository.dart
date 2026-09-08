import '../../../core/errors/result.dart';
import '../../../core/security/session_tokens.dart';
import '../domain/auth_repository.dart';
import '../domain/local_session.dart';

/// Lets any valid form in, with a token that only this device recognises —
/// the stand-in until the API issues real ones. It has no expiry, so the
/// session manager never asks to renew it.
final class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository();

  static const SessionTokens _local = SessionTokens(
    accessToken: localSessionToken,
  );

  @override
  Future<Result<SessionTokens>> signIn({
    required String identifier,
    required String password,
  }) async => const Success(_local);

  @override
  Future<Result<SessionTokens>> register(Registration registration) async =>
      const Success(_local);

  @override
  Future<Result<SessionTokens>> refresh(String refreshToken) async =>
      const Success(_local);

  @override
  Future<Result<void>> signOut() async => const Success<void>(null);
}
