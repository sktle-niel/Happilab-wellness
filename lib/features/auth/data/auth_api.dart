import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/security/session_tokens.dart';
import '../domain/auth_repository.dart';

/// [AuthRepository] over the API. The calls that establish a session carry
/// no bearer: there is none yet, or the one there is has run out.
final class AuthApi implements AuthRepository {
  const AuthApi(this._client);

  final ApiClient _client;

  @override
  Future<Result<SessionTokens>> signIn({
    required String identifier,
    required String password,
  }) => _client.post(
    ApiEndpoints.signIn,
    body: {'identifier': identifier, 'password': password},
    parse: SessionTokens.fromJson,
    authenticated: false,
  );

  @override
  Future<Result<SessionTokens>> register(Registration registration) =>
      _client.post(
        ApiEndpoints.register,
        body: {
          'full_name': registration.fullName,
          'email': registration.email,
          'password': registration.password,
          'referral_code': registration.referralCode,
        },
        parse: SessionTokens.fromJson,
        authenticated: false,
      );

  @override
  Future<Result<SessionTokens>> refresh(String refreshToken) => _client.post(
    ApiEndpoints.refresh,
    body: {'refresh_token': refreshToken},
    parse: SessionTokens.fromJson,
    authenticated: false,
  );

  @override
  Future<Result<void>> signOut() =>
      _client.post(ApiEndpoints.signOut, parse: (_) {});
}
