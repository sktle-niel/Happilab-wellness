/// HTTP verbs the app is allowed to send.
enum HttpMethod { get, post, put, patch, delete }

/// Transport-level contract.
///
/// `ApiClient` depends on this, not on a concrete HTTP package, so the whole
/// networking stack can be unit tested with a fake and swapping packages never
/// reaches feature code.
abstract interface class HttpTransport {
  Future<HttpTransportResponse> send(HttpTransportRequest request);

  void close();
}

class HttpTransportRequest {
  const HttpTransportRequest({
    required this.method,
    required this.url,
    this.headers = const <String, String>{},
    this.body,
  });

  final HttpMethod method;
  final Uri url;
  final Map<String, String> headers;

  /// JSON-encodable payload, or `null` for bodyless verbs.
  final Object? body;
}

class HttpTransportResponse {
  const HttpTransportResponse({
    required this.statusCode,
    required this.body,
    this.headers = const <String, String>{},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  bool get isRateLimited => statusCode == 429;

  bool get isServerError => statusCode >= 500;

  /// Server-instructed cooldown in delta-seconds form. An HTTP-date value is
  /// ignored rather than guessed — the retry policy then falls back to backoff.
  Duration? get retryAfter {
    final raw = headers['retry-after'];
    final seconds = raw == null ? null : int.tryParse(raw.trim());
    return (seconds == null || seconds < 0) ? null : Duration(seconds: seconds);
  }
}
