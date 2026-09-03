import 'package:flutter/material.dart';

import 'di/app_dependencies.dart';
import 'di/app_scope.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'session_guard.dart';
import 'theme/app_theme.dart';
import 'theme/theme_reveal.dart';

/// Application shell: dependency scope, session guard, theme and routing. It
/// holds no feature logic — that belongs in `features/`.
///
/// Stateful only to own the navigator and messenger keys the guard steers by.
class HappilabApp extends StatefulWidget {
  const HappilabApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<HappilabApp> createState() => _HappilabAppState();
}

class _HappilabAppState extends State<HappilabApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) => AppScope(
    dependencies: widget.dependencies,
    child: SessionGuard(
      session: widget.dependencies.sessionManager,
      navigatorKey: _navigatorKey,
      messengerKey: _messengerKey,
      child: ThemeReveal(
        controller: widget.dependencies.themeController,
        child: ListenableBuilder(
          listenable: widget.dependencies.themeController,
          builder: (context, _) => MaterialApp(
            title: 'Falcon Crest Ventures',
            debugShowCheckedModeBanner: false,
            navigatorKey: _navigatorKey,
            scaffoldMessengerKey: _messengerKey,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: widget.dependencies.themeController.mode,
            // The reveal does the transition; a cross-fade underneath it would
            // only bleed the old palette through the hole.
            themeAnimationDuration: Duration.zero,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ),
      ),
    ),
  );
}
