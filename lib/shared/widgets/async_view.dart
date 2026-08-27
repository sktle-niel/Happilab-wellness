import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import 'error_view.dart';

/// Renders the three states of an async read — loading, failure, data — so no
/// screen has to hand-roll them again.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    required this.future,
    required this.builder,
    this.onRetry,
    super.key,
  });

  final Future<Result<T>> future;
  final Widget Function(BuildContext context, T value) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => FutureBuilder<Result<T>>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return ErrorView(error: const UnknownException(), onRetry: onRetry);
      }

      final result = snapshot.data;
      if (result == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return result.fold(
        (value) => builder(context, value),
        (error) => ErrorView(error: error, onRetry: onRetry),
      );
    },
  );
}
