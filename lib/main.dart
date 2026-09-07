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
  // The palette is read back before the first frame, so a member who chose
  // dark never sees the app flash light on the way in. The launch screen
  // covers the wait.
  await dependencies.themeController.restore();
  runApp(HappilabApp(dependencies: dependencies));
}
