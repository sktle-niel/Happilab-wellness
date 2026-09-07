import 'dart:async';

import '../../core/config/app_config.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/api_client.dart';
import '../../core/network/http_transport.dart';
import '../../core/network/io_http_transport.dart';
import '../../core/network/rate_limiter.dart';
import '../../core/security/secure_token_store.dart';
import '../../core/security/session_manager.dart';
import '../../core/security/token_store.dart';
import '../../shared/domain/payout_account.dart';
import '../../shared/domain/profile_photo.dart';
import '../../shared/utils/native_photo_library.dart';
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
    required this.sessionManager,
    required this.apiClient,
    required this.profilePhoto,
    required this.payoutAccounts,
    ThemeController? themeController,
  }) : themeController = themeController ?? ThemeController() {
    // Any session boundary — in or out — drops cached responses: one member's
    // data must never be served into another's session.
    sessionManager.addListener(apiClient.clearCache);
    // The picture is the member's; a phone the next member signs in on must
    // not still wear it.
    sessionManager.addListener(_forgetPhotoWhenSignedOut);
    // The wallets too: they are the member's, not the phone's.
    sessionManager.addListener(_forgetPayoutAccountsWhenSignedOut);
  }

  factory AppDependencies.production() {
    final config = AppConfig.fromEnvironment();
    final logger = AppLogger.forEnvironment(isProduction: config.isProduction);
    final sessionManager = SessionManager(store: SecureTokenStore());
    final transport = IoHttpTransport(timeout: config.requestTimeout);

    return AppDependencies(
      config: config,
      logger: logger,
      sessionManager: sessionManager,
      apiClient: ApiClient(
        config: config,
        transport: transport,
        tokenStore: sessionManager,
        logger: logger,
        rateLimiter: RateLimiter.perMinute(config.maxRequestsPerMinute),
      ),
      profilePhoto: ProfilePhoto(library: const NativePhotoLibrary()),
      payoutAccounts: PayoutAccounts(),
      // Its own entry in the secure store, apart from the token.
      themeController: ThemeController(
        store: SecureTokenStore(key: 'theme_mode'),
        logger: logger,
      ),
    );
  }

  /// Wires the real graph around a caller-supplied [transport] — the seam tests
  /// and previews use instead of touching the network. Credentials stay in
  /// memory here: secure storage needs a platform channel that a widget test
  /// does not have. [photoLibrary] is the same seam for the picker, and
  /// [payoutAccounts] lets a test start with wallets already saved.
  factory AppDependencies.withTransport({
    required AppConfig config,
    required HttpTransport transport,
    PhotoLibrary? photoLibrary,
    PayoutAccounts? payoutAccounts,
  }) {
    final logger = AppLogger.forEnvironment(isProduction: config.isProduction);
    final sessionManager = SessionManager(store: InMemoryTokenStore());

    return AppDependencies(
      config: config,
      logger: logger,
      sessionManager: sessionManager,
      apiClient: ApiClient(
        config: config,
        transport: transport,
        tokenStore: sessionManager,
        logger: logger,
      ),
      profilePhoto: ProfilePhoto(
        library: photoLibrary ?? const NativePhotoLibrary(),
      ),
      payoutAccounts: payoutAccounts ?? PayoutAccounts(),
      themeController: ThemeController(logger: logger),
    );
  }

  final AppConfig config;
  final AppLogger logger;

  /// The session, observable — also the token store `apiClient` reads, so a
  /// rejected token and an explicit log-out land in the same place.
  final SessionManager sessionManager;
  final ApiClient apiClient;

  /// The member's picture, observable — every avatar of them draws from it.
  final ProfilePhoto profilePhoto;

  /// The member's payout wallets, observable — the cash-out picker and the
  /// edit form share them.
  final PayoutAccounts payoutAccounts;

  /// Light or dark, chosen by the member for the session.
  final ThemeController themeController;

  void _forgetPhotoWhenSignedOut() {
    if (!sessionManager.isSignedIn) unawaited(profilePhoto.remove());
  }

  void _forgetPayoutAccountsWhenSignedOut() {
    if (!sessionManager.isSignedIn) payoutAccounts.clear();
  }

  void dispose() {
    themeController.dispose();
    profilePhoto.dispose();
    payoutAccounts.dispose();
    sessionManager.dispose();
    apiClient.close();
  }
}
