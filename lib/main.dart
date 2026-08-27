import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/app_dependencies.dart';

/// Entry point only: build the dependency graph once, then hand it to the app.
/// Anything more than this belongs in `app/` or in a feature.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HappilabApp(dependencies: AppDependencies.production()));
}
