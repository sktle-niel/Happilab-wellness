import '../../../core/errors/result.dart';

/// What the member gets back for their credentials: the token every other
/// call will carry, and when it runs out.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
}

/// Everything a new account needs, already validated by the form.
class Registration {
  const Registration({
    required this.fullName,
    required this.email,
    required this.password,
    required this.referralCode,
  });

  final String fullName;
  final String email;
  final String password;
  final String referralCode;
}

/// The way in and out.
///
/// The token a success carries is handed to the session manager; nothing
/// else in the app ever sees a credential.
abstract interface class AuthRepository {
  Future<Result<AuthSession>> signIn({
    required String identifier,
    required String password,
  });

  Future<Result<AuthSession>> register(Registration registration);

  /// Tells the server the session is over. The local session is cleared
  /// whatever this answers — a member who asked to leave has left.
  Future<Result<void>> signOut();
}
