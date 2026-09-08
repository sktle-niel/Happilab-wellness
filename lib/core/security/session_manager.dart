import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';
import '../errors/result.dart';
import 'session_tokens.dart';
import 'token_store.dart';

/// Where the member's session stands.
enum SessionStatus { unknown, signedOut, signedIn }

/// How the last session ended — an exit the member chose reads differently
/// from a token the server refused.
enum SessionEndReason { signedOut, revoked }

/// Trades a refresh token for a new pair. Bound to the API in the
/// composition root; the fakes hand back their local pair.
typedef SessionRefresher = Future<Result<SessionTokens>> Function(
  String refreshToken,
);

/// The session, as observable state.
///
/// It keeps the token pair in one [TokenStore] entry and is what `ApiClient`
/// reads its bearer from, so every way a session can change converges here:
/// sign-in writes the pair, log-out clears it, the client clearing a
/// rejected token on 401 flips the status, and an access token about to run
/// out is renewed — once, however many requests are waiting — before it is
/// handed over. Listeners (the navigation guard, the response cache) react
/// to the transition, never to the cause.
class SessionManager extends ChangeNotifier implements RequestCredentials {
  SessionManager({
    required this._store,
    required this._refresh,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// How close to expiry a token is still sent. Wide enough that a device
  /// clock a minute or two behind the server's does not send a token the
  /// server has already retired.
  static const Duration refreshMargin = Duration(minutes: 2);

  final TokenStore _store;
  final SessionRefresher _refresh;
  final DateTime Function() _clock;

  SessionTokens? _tokens;
  SessionStatus _status = SessionStatus.unknown;
  SessionEndReason? _endReason;
  Future<void>? _restoring;
  Future<void>? _renewing;

  SessionStatus get status => _status;

  bool get isSignedIn => _status == SessionStatus.signedIn;

  /// Why the session most recently ended, or null while one has never ended.
  SessionEndReason? get endReason => _endReason;

  /// Loads the persisted session, once — later calls await the same read, so
  /// any screen can call this without racing another.
  Future<void> restore() => _restoring ??= _restore();

  Future<void> _restore() async {
    final stored = await _store.read();
    _tokens = stored == null ? null : SessionTokens.decode(stored);
    _moveTo(_tokens == null ? SessionStatus.signedOut : SessionStatus.signedIn);
  }

  /// Persists [tokens] and raises the session.
  Future<void> signIn(SessionTokens tokens) async {
    await _keep(tokens);
    _restoring ??= Future<void>.value();
    _endReason = null;
    _moveTo(SessionStatus.signedIn);
  }

  /// The member chose to leave.
  Future<void> signOut() => _end(SessionEndReason.signedOut);

  /// The access token a request should carry, renewed first when it is
  /// about to run out; null when there is no session.
  @override
  Future<String?> read() async {
    await restore();
    final tokens = _tokens;
    if (tokens == null) return null;
    final refreshToken = tokens.refreshToken;
    if (refreshToken != null && tokens.expiresWithin(refreshMargin, _clock())) {
      await (_renewing ??= _renew(refreshToken));
    }
    return _tokens?.accessToken;
  }

  /// One renewal serves every request waiting on it. A refused refresh
  /// token means the session is over — its family was revoked or it ran
  /// out — so the session ends as revoked. Any other failure keeps the pair
  /// in hand: the request goes out with it and the server has the last
  /// word. A session that ended while the renewal was in flight stays
  /// ended; the new pair is dropped rather than resurrecting it.
  Future<void> _renew(String refreshToken) async {
    try {
      final outcome = await _refresh(refreshToken);
      final error = outcome.errorOrNull;
      if (error is UnauthorizedException) {
        await clear();
      } else if (error == null && _tokens != null) {
        await _keep(outcome.valueOrNull!);
      }
    } finally {
      _renewing = null;
    }
  }

  Future<void> _keep(SessionTokens tokens) async {
    await _store.write(tokens.encode());
    _tokens = tokens;
  }

  /// The [RequestCredentials] contract's clear is the 401 path: the server
  /// refused the token, so the session was revoked rather than closed.
  @override
  Future<void> clear() => _end(SessionEndReason.revoked);

  Future<void> _end(SessionEndReason reason) async {
    // Gone from memory first: a request racing this must not pick it up.
    _tokens = null;
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
