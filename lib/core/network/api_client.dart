import 'dart:convert';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../errors/result.dart';
import '../logging/app_logger.dart';
import '../security/token_store.dart';
import 'http_transport.dart';
import 'rate_limiter.dart';
import 'response_cache.dart';
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
    this._cache,
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
    ResponseCache? cache,
  }) => ApiClient._(
    config,
    transport,
    tokenStore,
    logger,
    rateLimiter ?? RateLimiter.perMinute(config.maxRequestsPerMinute),
    retryPolicy ?? RetryPolicy(maxAttempts: config.maxRetries + 1),
    cache ?? ResponseCache(),
  );

  final AppConfig _config;
  final HttpTransport _transport;
  final TokenStore _tokenStore;
  final AppLogger _logger;
  final RateLimiter _rateLimiter;
  final RetryPolicy _retryPolicy;
  final ResponseCache _cache;

  /// [maxAge] opts the read into the cache: a fresh hit skips the network and
  /// the rate limit entirely, and when the backend is unreachable a stale hit
  /// stands in for it. Leave it null for anything that must be live.
  Future<Result<T>> get<T>(
    String path, {
    required JsonParser<T> parse,
    Map<String, String>? query,
    Duration? maxAge,
  }) => _send(
    method: HttpMethod.get,
    path: path,
    parse: parse,
    query: query,
    maxAge: maxAge,
  );

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

  /// Drops every cached response. Called on any session boundary — one
  /// member's data must never be served into another's session.
  void clearCache() => _cache.clear();

  void close() => _transport.close();

  Future<Result<T>> _send<T>({
    required HttpMethod method,
    required String path,
    required JsonParser<T> parse,
    Map<String, String>? query,
    Object? body,
    Duration? maxAge,
  }) async {
    final url = _resolve(path, query);

    if (maxAge != null) {
      final hit = _fromCache(url, parse);
      if (hit != null) return hit;
    }

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
          final decoded = _decode(response.body);
          if (maxAge != null) {
            _cache.write(url, decoded, maxAge);
          } else if (method != HttpMethod.get) {
            // A write changes what any read might return. Precise per-resource
            // invalidation is not worth its bookkeeping at this cache's size.
            _cache.clear();
          }
          return Success<T>(parse(decoded));
        }

        if (!_retryPolicy.shouldRetry(
          attempt: attempt,
          statusCode: response.statusCode,
        )) {
          final failure = await _failureFor(method, url, response);
          return _staleFallback(url, parse, failure, maxAge: maxAge) ??
              Failure<T>(failure);
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
          return _staleFallback(url, parse, error, maxAge: maxAge) ??
              Failure<T>(error);
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

  /// A fresh cache hit, parsed — or null so the caller goes to the network.
  /// A cached body that no longer parses is treated as a miss, never a crash.
  Result<T>? _fromCache<T>(Uri url, JsonParser<T> parse) {
    final hit = _cache.readFresh(url);
    if (hit == null) return null;
    try {
      return Success<T>(parse(hit.json));
    } catch (_) {
      return null;
    }
  }

  /// When the backend is the problem, an out-of-date answer beats none: a
  /// cached read — even an expired one — stands in and the failure goes to the
  /// log. Auth and 4xx failures surface untouched; hiding those would lie.
  Result<T>? _staleFallback<T>(
    Uri url,
    JsonParser<T> parse,
    AppException error, {
    required Duration? maxAge,
  }) {
    if (maxAge == null || !_isBackendFault(error)) return null;
    final stale = _cache.readStale(url);
    if (stale == null) return null;
    try {
      final value = parse(stale.json);
      _logger.warning('Serving stale cache for $url after: $error');
      return Success<T>(value);
    } catch (_) {
      return null;
    }
  }

  static bool _isBackendFault(AppException error) =>
      error is NetworkException ||
      error is RequestTimeoutException ||
      error is ServerException ||
      error is RateLimitedException;

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
