import 'dart:convert';

import '../errors/app_exception.dart';
import '../utils/json_reader.dart';

/// What a sign-in leaves the device holding: the bearer every request
/// carries, the token that renews it, and when the bearer runs out.
///
/// A pair with no refresh token or no expiry is never renewed — the fakes'
/// local session, or a server that issued only an access token — and lasts
/// until the server refuses it.
final class SessionTokens {
  const SessionTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  /// Whether the access token runs out within [margin] of [now]. Never,
  /// when it has no expiry.
  bool expiresWithin(Duration margin, DateTime now) {
    final expiry = expiresAt;
    return expiry != null && !now.add(margin).isBefore(expiry);
  }

  /// The wire shape, which is also how the pair is kept in secure storage.
  String encode() => jsonEncode({
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expires_at': expiresAt?.toUtc().toIso8601String(),
  });

  /// [json] is a decoded response or a stored entry; a shape off the
  /// contract is a [DataFormatException].
  static SessionTokens fromJson(Object? json) {
    final reader = JsonReader.of(json);
    return SessionTokens(
      accessToken: reader.string('access_token'),
      refreshToken: reader.optionalString('refresh_token'),
      expiresAt: reader.optionalDateTime('expires_at'),
    );
  }

  /// A stored entry, or null when it cannot be read — written by an older
  /// build, or damaged — which counts as no session at all.
  static SessionTokens? decode(String stored) {
    try {
      return fromJson(jsonDecode(stored));
    } on FormatException {
      return null;
    } on DataFormatException {
      return null;
    }
  }
}
