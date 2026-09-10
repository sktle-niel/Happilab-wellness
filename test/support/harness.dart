import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/di/app_dependencies.dart';
import 'package:happilab/app/di/app_scope.dart';
import 'package:happilab/app/di/repositories.dart';
import 'package:happilab/app/router/app_router.dart';
import 'package:happilab/app/theme/app_scroll_behavior.dart';
import 'package:happilab/app/theme/app_theme.dart';
import 'package:happilab/app/theme/theme_reveal.dart';
import 'package:happilab/core/config/app_config.dart';
import 'package:happilab/shared/domain/delivery_address.dart';
import 'package:happilab/shared/domain/payout_account.dart';
import 'package:happilab/shared/domain/profile_photo.dart';
import 'package:happilab/shared/widgets/app_backdrop.dart';

import 'fake_http_transport.dart';
import 'fake_photo_library.dart';

/// Boots the real scope, router and theme at [initialRoute], so navigation
/// between screens under test behaves exactly as it does in the app — with a
/// scripted transport in place of the network.
///
/// [onGenerateInitialRoutes] is overridden because a path like `/sign-in`
/// otherwise makes Navigator build `/` underneath it: the screen under test
/// would start with a hidden splash below it, `canPop()` would lie, and a back
/// button would appear to work while going somewhere else entirely.
Widget testApp({
  required String initialRoute,
  PhotoLibrary? photoLibrary,
  Iterable<PayoutAccount> payoutAccounts = const [],
  DeliveryAddress? deliveryAddress,
}) {
  final dependencies = AppDependencies.withTransport(
    config: AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: Uri.parse('https://api.test.local'),
    ),
    transport: FakeHttpTransport(),
    photoLibrary: photoLibrary ?? FakePhotoLibrary(),
    repositories: Repositories.fake(
      payoutAccounts: payoutAccounts,
      deliveryAddress: deliveryAddress,
    ),
  );

  return AppScope(
    dependencies: dependencies,
    child: ThemeReveal(
      controller: dependencies.themeController,
      child: ListenableBuilder(
        listenable: dependencies.themeController,
        builder: (context, _) => MaterialApp(
          scrollBehavior: const AppScrollBehavior(),
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: dependencies.themeController.mode,
          themeAnimationDuration: Duration.zero,
          initialRoute: initialRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onGenerateInitialRoutes: (route) => [
            AppRouter.onGenerateRoute(RouteSettings(name: route)),
          ],
          builder: (context, child) => AppBackdrop(child: child),
        ),
      ),
    ),
  );
}

/// Sizes the test surface like the phone frame in the design canvas.
///
/// The 800x600 default is neither phone-shaped nor tall enough for a form, so
/// screens that fit on a real device would fail here for the wrong reason.
void usePhoneViewport(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(402 * 3, 874 * 3)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Scrolls [finder] into view before tapping it — a long form pushes its submit
/// button below the fold, exactly as it does for a real user.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  // A plain pump, not pumpAndSettle: several screens animate forever, so there
  // is no settled frame to wait for.
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(finder);
}

/// Waits out a bottom sheet's entrance — or exit — animation.
Future<void> settleSheet(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
