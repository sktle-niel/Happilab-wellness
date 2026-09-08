import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/app_dependencies.dart';
import 'core/errors/global_error_handler.dart';

/// Entry point only: build the dependency graph once, then hand it to the app.
/// Anything more than this belongs in `app/` or in a feature.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.production();
  GlobalErrorHandler.install(dependencies.logger);
  // The palette and the hidden balance are read back before the first frame,
  // so a member who chose dark never sees the app flash light on the way in,
  // and a hidden figure never flashes into view. The launch screen covers
  // the wait.
  await Future.wait([
    dependencies.themeController.restore(),
    dependencies.balanceHidden.restore(),
  ]);
  runApp(HappilabApp(dependencies: dependencies));
}
