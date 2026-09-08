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
import '../../core/storage/persisted_flag.dart';
import '../../shared/domain/member_store.dart';
import '../../shared/domain/payout_account.dart';
import '../../shared/domain/profile_photo.dart';
import '../../shared/utils/native_photo_library.dart';
import '../theme/theme_controller.dart';
import 'repositories.dart';

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
    required this.repositories,
    required this.profilePhoto,
    required this.balanceHidden,
    ThemeController? themeController,
  }) : themeController = themeController ?? ThemeController(),
       member = MemberStore(repositories.member),
       payoutAccounts = PayoutAccounts(repositories.payoutAccounts) {
    // Any session boundary — in or out — drops cached responses: one member's
    // data must never be served into another's session.
    sessionManager.addListener(apiClient.clearCache);
    // The picture is the member's; a phone the next member signs in on must
    // not still wear it.
    sessionManager.addListener(_forgetPhotoWhenSignedOut);
    // The wallets too, and the member's own figures: theirs, not the phone's.
    sessionManager.addListener(_forgetMemberWhenSignedOut);
  }

  factory AppDependencies.production() {
    final config = AppConfig.fromEnvironment();
    final logger = AppLogger.forEnvironment(isProduction: config.isProduction);
    // The session renews itself through the auth repository, which sits on
    // the client the session authenticates. The cycle closes here, lazily:
    // the tear-off is only ever called once a request is on its way.
    late final Repositories repositories;
    final sessionManager = SessionManager(
      store: SecureTokenStore(),
      refresh: (token) => repositories.auth.refresh(token),
    );
    final transport = IoHttpTransport(timeout: config.requestTimeout);
    final apiClient = ApiClient(
      config: config,
      transport: transport,
      credentials: sessionManager,
      logger: logger,
      rateLimiter: RateLimiter.perMinute(config.maxRequestsPerMinute),
    );
    repositories = Repositories.forConfig(config, apiClient);

    return AppDependencies(
      config: config,
      logger: logger,
      sessionManager: sessionManager,
      apiClient: apiClient,
      repositories: repositories,
      profilePhoto: ProfilePhoto(library: const NativePhotoLibrary()),
      // Their own entries in the secure store, apart from the token.
      themeController: ThemeController(
        store: SecureTokenStore(key: 'theme_mode'),
        logger: logger,
      ),
      balanceHidden: PersistedFlag(
        store: SecureTokenStore(key: 'balance_hidden'),
        logger: logger,
        onValue: 'hidden',
      ),
    );
  }

  /// Wires the real graph around a caller-supplied [transport] — the seam tests
  /// and previews use instead of touching the network. Credentials stay in
  /// memory here: secure storage needs a platform channel that a widget test
  /// does not have. [photoLibrary] is the same seam for the picker, and
  /// [repositories] lets a test hand in its own data — the fakes otherwise.
  factory AppDependencies.withTransport({
    required AppConfig config,
    required HttpTransport transport,
    PhotoLibrary? photoLibrary,
    Repositories? repositories,
  }) {
    final logger = AppLogger.forEnvironment(isProduction: config.isProduction);
    final bound = repositories ?? Repositories.fake();
    final sessionManager = SessionManager(
      store: InMemoryTokenStore(),
      refresh: bound.auth.refresh,
    );

    return AppDependencies(
      config: config,
      logger: logger,
      sessionManager: sessionManager,
      apiClient: ApiClient(
        config: config,
        transport: transport,
        credentials: sessionManager,
        logger: logger,
      ),
      repositories: bound,
      profilePhoto: ProfilePhoto(
        library: photoLibrary ?? const NativePhotoLibrary(),
      ),
      themeController: ThemeController(logger: logger),
      balanceHidden: PersistedFlag(store: InMemoryTokenStore(), logger: logger),
    );
  }

  final AppConfig config;
  final AppLogger logger;

  /// The session, observable — also the credentials `apiClient` reads, so a
  /// rejected token and an explicit log-out land in the same place.
  final SessionManager sessionManager;
  final ApiClient apiClient;

  /// Every data source, behind its contract — API or the bundled fakes.
  final Repositories repositories;

  /// The signed-in member's figures, observable, loaded once per session.
  final MemberStore member;

  /// The member's picture, observable — every avatar of them draws from it.
  final ProfilePhoto profilePhoto;

  /// The member's payout wallets, observable — the cash-out picker and the
  /// edit form share them.
  final PayoutAccounts payoutAccounts;

  /// Light or dark, chosen by the member.
  final ThemeController themeController;

  /// Whether the member keeps their balance out of sight — on home, on cash
  /// out, wherever the figure shows. Set once, it holds everywhere.
  final PersistedFlag balanceHidden;

  void _forgetPhotoWhenSignedOut() {
    if (!sessionManager.isSignedIn) unawaited(profilePhoto.remove());
  }

  void _forgetMemberWhenSignedOut() {
    if (sessionManager.isSignedIn) return;
    payoutAccounts.clear();
    member.reset();
  }

  void dispose() {
    themeController.dispose();
    balanceHidden.dispose();
    profilePhoto.dispose();
    payoutAccounts.dispose();
    member.dispose();
    sessionManager.dispose();
    apiClient.close();
  }
}
