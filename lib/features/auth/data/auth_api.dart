import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/json_reader.dart';
import '../domain/auth_repository.dart';

/// [AuthRepository] over the API.
final class AuthApi implements AuthRepository {
  const AuthApi(this._client);

  final ApiClient _client;

  @override
  Future<Result<AuthSession>> signIn({
    required String identifier,
    required String password,
  }) => _client.post(
    ApiEndpoints.signIn,
    body: {'identifier': identifier, 'password': password},
    parse: _session,
  );

  @override
  Future<Result<AuthSession>> register(Registration registration) =>
      _client.post(
        ApiEndpoints.register,
        body: {
          'full_name': registration.fullName,
          'email': registration.email,
          'password': registration.password,
          'referral_code': registration.referralCode,
        },
        parse: _session,
      );

  @override
  Future<Result<void>> signOut() =>
      _client.post(ApiEndpoints.signOut, parse: (_) {});

  static AuthSession _session(Object? json) {
    final reader = JsonReader.of(json);
    return AuthSession(
      accessToken: reader.string('access_token'),
      refreshToken: reader.optionalString('refresh_token'),
      expiresAt: reader.optionalDateTime('expires_at'),
    );
  }
}
