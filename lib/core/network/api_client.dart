import 'dart:convert';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../errors/result.dart';
import '../logging/app_logger.dart';
import '../security/token_store.dart';
import 'http_transport.dart';
import 'rate_limiter.dart';
import 'retry_policy.dart';

/// Turns raw JSON into a typed model.
typedef JsonParser<T> = T Function(Object? json);

/// The only way the app talks to the network.
///
/// Every call is rate limited, authenticated, timed out, retried with backoff
/// on transient failures, and mapped to a [Result]. Feature code never sees a
/// status code, a header or an exception — repositories call this and switch on
/// the result.
class ApiClient {
  ApiClient._(
    this._config,
    this._transport,
    this._tokenStore,
    this._logger,
    this._rateLimiter,
    this._retryPolicy,
  );

  /// Defaults come from [AppConfig], so the limiter and the retry budget are
  /// configured per flavor instead of being hardcoded at the call site.
  factory ApiClient({
    required AppConfig config,
    required HttpTransport transport,
    required TokenStore tokenStore,
    required AppLogger logger,
    RateLimiter? rateLimiter,
    RetryPolicy? retryPolicy,
  }) => ApiClient._(
    config,
    transport,
    tokenStore,
    logger,
    rateLimiter ?? RateLimiter.perMinute(config.maxRequestsPerMinute),
    retryPolicy ?? RetryPolicy(maxAttempts: config.maxRetries + 1),
  );

  final AppConfig _config;
  final HttpTransport _transport;
  final TokenStore _tokenStore;
  final AppLogger _logger;
  final RateLimiter _rateLimiter;
  final RetryPolicy _retryPolicy;

  Future<Result<T>> get<T>(
    String path, {
    required JsonParser<T> parse,
    Map<String, String>? query,
  }) => _send(method: HttpMethod.get, path: path, parse: parse, query: query);

  Future<Result<T>> post<T>(
    String path, {
    required JsonParser<T> parse,
    Object? body,
  }) => _send(method: HttpMethod.post, path: path, parse: parse, body: body);

  Future<Result<T>> put<T>(
    String path, {
    required JsonParser<T> parse,
    Object? body,
  }) => _send(method: HttpMethod.put, path: path, parse: parse, body: body);

  Future<Result<T>> delete<T>(String path, {required JsonParser<T> parse}) =>
      _send(method: HttpMethod.delete, path: path, parse: parse);

  void close() => _transport.close();

  Future<Result<T>> _send<T>({
    required HttpMethod method,
    required String path,
    required JsonParser<T> parse,
    Map<String, String>? query,
    Object? body,
  }) async {
    final url = _resolve(path, query);

    for (var attempt = 1; ; attempt++) {
      try {
        final request = HttpTransportRequest(
          method: method,
          url: url,
          headers: await _headers(),
          body: body,
        );

        // The timeout sits inside the limiter so time spent waiting for a slot
        // is never mistaken for a slow server.
        final response = await _rateLimiter.run(
          () => _transport
              .send(request)
              .timeout(
                _config.requestTimeout,
                onTimeout: () => throw const RequestTimeoutException(),
              ),
        );

        if (response.isSuccess) {
          return Success<T>(parse(_decode(response.body)));
        }

        if (!_retryPolicy.shouldRetry(
          attempt: attempt,
          statusCode: response.statusCode,
        )) {
          return Failure<T>(await _failureFor(method, url, response));
        }

        await Future<void>.delayed(
          _retryPolicy.delayFor(attempt, retryAfter: response.retryAfter),
        );
      } on AppException catch (error) {
        final isTransient =
            error is NetworkException || error is RequestTimeoutException;
        if (!isTransient ||
            !_retryPolicy.shouldRetry(attempt: attempt, statusCode: null)) {
          _logger.error('${method.name.toUpperCase()} $url failed: $error');
          return Failure<T>(error);
        }
        await Future<void>.delayed(_retryPolicy.delayFor(attempt));
      } catch (error, stackTrace) {
        _logger.error(
          'Unhandled failure calling $url',
          error: error,
          stackTrace: stackTrace,
        );
        return Failure<T>(const UnknownException());
      }
    }
  }

  Uri _resolve(String path, Map<String, String>? query) {
    final relative = path.startsWith('/') ? path.substring(1) : path;
    final url = _config.apiBaseUrl.resolve(relative);
    return (query == null || query.isEmpty)
        ? url
        : url.replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _tokenStore.read();
    return <String, String>{
      'accept': 'application/json',
      if (token != null) 'authorization': 'Bearer $token',
    };
  }

  /// A rejected session is dropped immediately — holding a token the server has
  /// already refused only invites replay.
  Future<AppException> _failureFor(
    HttpMethod method,
    Uri url,
    HttpTransportResponse response,
  ) async {
    final failure = _mapStatus(response);
    if (failure is UnauthorizedException) await _tokenStore.clear();
    _logger.warning(
      '${method.name.toUpperCase()} $url → ${response.statusCode}',
    );
    return failure;
  }

  static AppException _mapStatus(HttpTransportResponse response) =>
      switch (response.statusCode) {
        401 || 403 => const UnauthorizedException(),
        429 => RateLimitedException(retryAfter: response.retryAfter),
        final code when code >= 500 => ServerException(code),
        final code => ClientException(code),
      };

  static Object? _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const DataFormatException();
    }
  }
}
