import 'package:flutter/material.dart';

import 'di/app_dependencies.dart';
import 'di/app_scope.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'theme/app_theme.dart';

/// Application shell: dependency scope, theme and routing. It holds no feature
/// logic — that belongs in `features/`.
class HappilabApp extends StatelessWidget {
  const HappilabApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) => AppScope(
    dependencies: dependencies,
    child: MaterialApp(
      title: 'Happilab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.counter,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ),
  );
}
