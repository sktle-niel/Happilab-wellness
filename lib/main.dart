import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/app_dependencies.dart';
import 'core/errors/global_error_handler.dart';

/// Entry point only: build the dependency graph once, then hand it to the app.
/// Anything more than this belongs in `app/` or in a feature.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.production();
  GlobalErrorHandler.install(dependencies.logger);
  runApp(HappilabApp(dependencies: dependencies));
}
