import 'dart:convert';

import '../security/input_validator.dart';

/// The server's account of a failed request: `{ "error": code, "message":
/// sentence }`. The code names the rule that refused it and goes to the log;
/// the sentence was written for the member and goes to the screen.
///
/// Output from outside the process is untrusted all the same: anything that
/// is not exactly this shape is ignored, and the sentence is stripped of
/// control characters and capped before a toast can show it.
final class ServerError {
  const ServerError({required this.code, required this.message});

  /// Room for a sentence; a paragraph would not fit a toast anyway.
  static const int _messageLength = 200;
  static const int _codeLength = 32;

  final String code;
  final String message;

  /// The error in [body], or null when the body is anything else — an empty
  /// response, a proxy's HTML page, a shape the contract did not promise.
  static ServerError? parse(String body) {
    if (body.isEmpty) return null;
    final Object? json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      return null;
    }
    if (json is! Map) return null;
    final code = json['error'];
    final message = json['message'];
    if (code is! String || message is! String) return null;
    final sentence = InputValidator.sanitize(
      message,
      maxLength: _messageLength,
    );
    if (sentence.isEmpty) return null;
    return ServerError(
      code: InputValidator.sanitize(code, maxLength: _codeLength),
      message: sentence,
    );
  }
}
