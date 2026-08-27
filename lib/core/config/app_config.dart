/// Build flavors. Anything that must behave differently per flavor branches on
/// this — never on a hardcoded `if (kDebugMode)` sprinkled through features.
enum AppEnvironment { dev, staging, prod }

/// Immutable runtime configuration.
///
/// Values arrive through `--dart-define` at build time, so no endpoint, key or
/// credential is ever committed to source control. Secrets belong in the CI
/// secret store; this class only reads what the pipeline injected.
class AppConfig {
  AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.requestTimeout = const Duration(seconds: 20),
    this.maxRequestsPerMinute = 60,
    this.maxRetries = 3,
  }) : assert(maxRequestsPerMinute > 0, 'Rate limit must allow at least 1/min'),
       assert(maxRetries >= 0, 'Retry count cannot be negative') {
    _assertTransportIsSecure(apiBaseUrl, environment);
  }

  factory AppConfig.fromEnvironment() {
    const environment = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.happilab.app',
    );
    const requestsPerMinute = int.fromEnvironment(
      'API_MAX_REQUESTS_PER_MINUTE',
      defaultValue: 60,
    );

    return AppConfig(
      environment: AppEnvironment.values.firstWhere(
        (value) => value.name == environment,
        orElse: () => AppEnvironment.dev,
      ),
      apiBaseUrl: Uri.parse(baseUrl),
      maxRequestsPerMinute: requestsPerMinute,
    );
  }

  final AppEnvironment environment;
  final Uri apiBaseUrl;
  final Duration requestTimeout;

  /// Client-side ceiling enforced by `RateLimiter`. Keep it at or below the
  /// quota the backend advertises so the app throttles itself before the
  /// server has to.
  final int maxRequestsPerMinute;
  final int maxRetries;

  bool get isProduction => environment == AppEnvironment.prod;

  /// Plain HTTP is only tolerated against a local machine during development;
  /// anything shipped talks TLS or does not talk at all.
  static void _assertTransportIsSecure(Uri url, AppEnvironment environment) {
    if (url.isScheme('https')) return;

    final isLocalDev =
        environment == AppEnvironment.dev &&
        (url.host == 'localhost' || url.host == '127.0.0.1');
    if (isLocalDev) return;

    throw ArgumentError.value(
      url.toString(),
      'apiBaseUrl',
      'Insecure transport: the API base URL must use https',
    );
  }
}
