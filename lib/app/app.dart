import 'package:flutter/material.dart';

import 'di/app_dependencies.dart';
import 'di/app_scope.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'theme/app_theme.dart';
import 'theme/theme_reveal.dart';

/// Application shell: dependency scope, theme and routing. It holds no feature
/// logic — that belongs in `features/`.
class HappilabApp extends StatelessWidget {
  const HappilabApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) => AppScope(
    dependencies: dependencies,
    child: ThemeReveal(
      controller: dependencies.themeController,
      child: ListenableBuilder(
        listenable: dependencies.themeController,
        builder: (context, _) => MaterialApp(
          title: 'Falcon Crest Ventures',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: dependencies.themeController.mode,
          // The reveal does the transition; a cross-fade underneath it would
          // only bleed the old palette through the hole.
          themeAnimationDuration: Duration.zero,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    ),
  );
}
