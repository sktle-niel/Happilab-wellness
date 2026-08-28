import '../../core/config/app_config.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/api_client.dart';
import '../../core/network/http_transport.dart';
import '../../core/network/io_http_transport.dart';
import '../../core/network/rate_limiter.dart';
import '../../core/security/secure_token_store.dart';
import '../../core/security/token_store.dart';
import '../theme/theme_controller.dart';

/// Composition root.
///
/// Every service is constructed exactly once, here, and injected down the tree.
/// Nothing below this file reaches for a singleton or builds its own client, so
/// any dependency can be replaced in a test by passing a different instance.
class AppDependencies {
  AppDependencies({
    required this.config,
    required this.logger,
    required this.tokenStore,
    required this.apiClient,
    ThemeController? themeController,
  }) : themeController = themeController ?? ThemeController();

  factory AppDependencies.production() {
    final config = AppConfig.fromEnvironment();
    final logger = AppLogger.forEnvironment(isProduction: config.isProduction);
    final tokenStore = SecureTokenStore();
    final transport = IoHttpTransport(timeout: config.requestTimeout);

    return AppDependencies(
      config: config,
      logger: logger,
      tokenStore: tokenStore,
      apiClient: ApiClient(
        config: config,
        transport: transport,
        tokenStore: tokenStore,
        logger: logger,
        rateLimiter: RateLimiter.perMinute(config.maxRequestsPerMinute),
      ),
    );
  }

  /// Wires the real graph around a caller-supplied [transport] — the seam tests
  /// and previews use instead of touching the network. Credentials stay in
  /// memory here: secure storage needs a platform channel that a widget test
  /// does not have.
  factory AppDependencies.withTransport({
    required AppConfig config,
    required HttpTransport transport,
  }) {
    final logger = AppLogger.forEnvironment(isProduction: config.isProduction);
    final tokenStore = InMemoryTokenStore();

    return AppDependencies(
      config: config,
      logger: logger,
      tokenStore: tokenStore,
      apiClient: ApiClient(
        config: config,
        transport: transport,
        tokenStore: tokenStore,
        logger: logger,
      ),
    );
  }

  final AppConfig config;
  final AppLogger logger;
  final TokenStore tokenStore;
  final ApiClient apiClient;

  /// Light or dark, chosen by the member for the session.
  final ThemeController themeController;

  void dispose() {
    themeController.dispose();
    apiClient.close();
  }
}
