import '../../../core/errors/result.dart';
import '../../../core/security/session_tokens.dart';

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
/// The pair a success carries is handed to the session manager; nothing
/// else in the app ever sees a credential.
abstract interface class AuthRepository {
  Future<Result<SessionTokens>> signIn({
    required String identifier,
    required String password,
  });

  Future<Result<SessionTokens>> register(Registration registration);

  /// A new pair for a refresh token that is still good. The old token is
  /// spent either way: presenting it again is what ends the whole session.
  Future<Result<SessionTokens>> refresh(String refreshToken);

  /// Tells the server the session is over. The local session is cleared
  /// whatever this answers — a member who asked to leave has left.
  Future<Result<void>> signOut();
}
