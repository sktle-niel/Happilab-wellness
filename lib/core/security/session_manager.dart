import 'package:flutter/foundation.dart';

import 'token_store.dart';

/// Where the member's session stands.
enum SessionStatus { unknown, signedOut, signedIn }

/// How the last session ended — an exit the member chose reads differently
/// from a token the server refused.
enum SessionEndReason { signedOut, revoked }

/// The session, as observable state.
///
/// It decorates the real [TokenStore] and is bound as `ApiClient`'s store, so
/// every way a session can change converges here: sign-in writes the token,
/// log-out clears it, and the client clearing a rejected token on 401 flips
/// the status without any extra wiring. Listeners (the navigation guard, the
/// response cache) react to the transition, never to the cause.
class SessionManager extends ChangeNotifier implements TokenStore {
  SessionManager({required this._store});

  final TokenStore _store;

  SessionStatus _status = SessionStatus.unknown;
  SessionEndReason? _endReason;
  Future<void>? _restoring;

  SessionStatus get status => _status;

  bool get isSignedIn => _status == SessionStatus.signedIn;

  /// Why the session most recently ended, or null while one has never ended.
  SessionEndReason? get endReason => _endReason;

  /// Loads the persisted session, once — later calls await the same read, so
  /// any screen can call this without racing another.
  Future<void> restore() => _restoring ??= _restore();

  Future<void> _restore() async {
    final token = await _store.read();
    _moveTo(token == null ? SessionStatus.signedOut : SessionStatus.signedIn);
  }

  /// Persists [token] and raises the session.
  Future<void> signIn(String token) => write(token);

  /// The member chose to leave.
  Future<void> signOut() => _end(SessionEndReason.signedOut);

  @override
  Future<String?> read() => _store.read();

  @override
  Future<void> write(String token) async {
    await _store.write(token);
    _endReason = null;
    _moveTo(SessionStatus.signedIn);
  }

  /// The [TokenStore] contract's clear is the 401 path: the server refused the
  /// token, so the session was revoked rather than closed.
  @override
  Future<void> clear() => _end(SessionEndReason.revoked);

  Future<void> _end(SessionEndReason reason) async {
    await _store.clear();
    _endReason = reason;
    _moveTo(SessionStatus.signedOut);
  }

  void _moveTo(SessionStatus next) {
    if (next == _status) return;
    _status = next;
    notifyListeners();
  }
}
