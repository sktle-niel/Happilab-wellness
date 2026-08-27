import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import 'counter_controller.dart';
import 'widgets/counter_value.dart';

/// Owns the controller's lifecycle and nothing else: no layout maths, no
/// business rules, no direct network access.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final CounterController _controller = CounterController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Happilab',
    floatingActionButton: FloatingActionButton(
      onPressed: _controller.increment,
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    ),
    body: Center(
      // Only this subtree rebuilds when the value changes.
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => CounterValue(
          value: _controller.value,
          onReset: _controller.canReset ? _controller.reset : null,
        ),
      ),
    ),
  );
}
