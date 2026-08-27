import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/app_exception.dart';
import 'token_store.dart';

/// Platform-backed [TokenStore]: Keychain on iOS, an Android KeyStore-wrapped
/// AES-GCM entry on Android, DPAPI on Windows, libsecret on Linux.
///
/// The token is cached in memory after the first read so an authenticated
/// request does not pay for a platform-channel round trip every time; the cache
/// is the only copy that lives in the process, and it dies with it.
final class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage, this.key = _defaultKey})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // v11 defaults already use AES-GCM with RSA-OAEP key wrapping; the
            // namespace keeps this app's entries clear of any other instance.
            aOptions: AndroidOptions(storageNamespace: 'happilab'),
            // `unlocked` keeps the token unreadable while the device is locked,
            // and `_this_device` stops it riding an encrypted backup to a new
            // phone. Never enable `synchronizable` — that is iCloud sync.
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          );

  static const String _defaultKey = 'auth_token';

  final FlutterSecureStorage _storage;
  final String key;

  String? _cached;
  bool _isLoaded = false;

  @override
  Future<String?> read() async {
    if (_isLoaded) return _cached;
    try {
      _cached = await _storage.read(key: key);
    } on PlatformException {
      // Unreadable storage is indistinguishable from "not signed in", and the
      // user can always sign in again. Failing the read is the safe direction.
      _cached = null;
    }
    _isLoaded = true;
    return _cached;
  }

  @override
  Future<void> write(String token) async {
    try {
      await _storage.write(key: key, value: token);
    } on PlatformException {
      throw const SecureStorageException();
    }
    _cached = token;
    _isLoaded = true;
  }

  @override
  Future<void> clear() async {
    // Drop the in-process copy first: whatever the platform does next, this
    // session is already dead and no request can pick the token back up.
    _cached = null;
    _isLoaded = true;
    try {
      await _storage.delete(key: key);
    } on PlatformException {
      // Deliberately not rethrown: clear() runs while handling a 401, and a
      // storage error must not mask the auth failure the caller is reporting.
      // The stale entry is overwritten by the next successful sign-in.
    }
  }
}
