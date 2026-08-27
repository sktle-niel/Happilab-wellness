import 'package:flutter/material.dart';

import '../../features/counter/presentation/counter_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'app_routes.dart';

/// Central route table.
///
/// Navigation lives here rather than inside screens: a feature stays unaware of
/// what comes before or after it, and an unknown deep link lands somewhere sane
/// instead of crashing.
abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: switch (settings.name) {
          AppRoutes.counter => (_) => const CounterScreen(),
          _ => (_) => const _RouteNotFoundScreen(),
        },
      );
}

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen();

  @override
  Widget build(BuildContext context) => const AppScaffold(
    title: 'Not found',
    body: Center(child: Text('This screen does not exist.')),
  );
}
