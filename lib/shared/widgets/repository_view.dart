import 'package:flutter/material.dart';

import '../../app/di/app_scope.dart';
import '../../app/di/repositories.dart';
import '../../core/errors/result.dart';
import 'async_view.dart';

/// Reads one thing from a repository and renders the three states of the
/// read — placeholders, failure with a retry, data — so a screen only says
/// what to read and what the data looks like.
///
/// Stateful so the read is made once: a future created inside `build` would
/// be remade, and refetched, on every rebuild.
class RepositoryView<T> extends StatefulWidget {
  const RepositoryView({
    required this.read,
    required this.builder,
    this.skeleton,
    super.key,
  });

  final Future<Result<T>> Function(Repositories repositories) read;
  final Widget Function(BuildContext context, T value) builder;

  /// What loading looks like; the loader when none is given.
  final Widget? skeleton;

  @override
  State<RepositoryView<T>> createState() => _RepositoryViewState<T>();
}

class _RepositoryViewState<T> extends State<RepositoryView<T>> {
  Future<Result<T>>? _read;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _read ??= widget.read(AppScope.of(context).repositories);
  }

  void _retry() =>
      setState(() => _read = widget.read(AppScope.of(context).repositories));

  @override
  Widget build(BuildContext context) => AsyncView<T>(
    future: _read!,
    builder: widget.builder,
    skeleton: widget.skeleton,
    onRetry: _retry,
  );
}
