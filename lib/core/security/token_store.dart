/// Contract for persisting credentials.
///
/// Features depend on this interface, never on a storage package, so hardening
/// storage later is a one-line change in the composition root.
abstract interface class TokenStore {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}

/// Process-memory implementation: nothing is written to disk, so nothing can
/// leak from disk. This is the safe default until the app gains a real login.
///
/// When it does, add a platform-secure implementation (Keychain on iOS,
/// EncryptedSharedPreferences on Android) and bind it in `AppDependencies`.
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
