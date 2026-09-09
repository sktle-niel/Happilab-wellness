/// What a request needs from the session: the credential to send, and a
/// way to drop it when the server refuses it.
///
/// `ApiClient` depends on this and nothing more, so the session that keeps
/// a token pair and the bare store a test hands over are interchangeable.
abstract interface class RequestCredentials {
  Future<String?> read();

  Future<void> clear();
}

/// Contract for persisting one credential.
///
/// Features depend on this interface, never on a storage package, so hardening
/// storage later is a one-line change in the composition root.
abstract interface class TokenStore implements RequestCredentials {
  Future<void> write(String token);
}

/// Process-memory implementation: nothing is written to disk, so nothing can
/// leak from disk. Tests and previews use it in place of the platform store.
/// Tokens must never land in SharedPreferences, a plain file, or a log line.
final class InMemoryTokenStore implements TokenStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
