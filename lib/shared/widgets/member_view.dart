import 'package:flutter/material.dart';

import '../../app/di/app_scope.dart';
import '../domain/member_store.dart';
import '../domain/member_summary.dart';
import 'app_loader.dart';
import 'error_view.dart';

/// Builds with the signed-in member once they are loaded, and shows the
/// wait — or the failure, with a retry — until then.
///
/// Stateful only to ask the store for the member once it is on screen; the
/// first view to appear is what triggers the read.
class MemberView extends StatefulWidget {
  const MemberView({required this.builder, this.skeleton, super.key});

  final Widget Function(BuildContext context, MemberSummary member) builder;

  /// What the wait looks like; the loader when none is given.
  final Widget? skeleton;

  @override
  State<MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends State<MemberView> {
  MemberStore get _store => AppScope.of(context).member;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store.load();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _store,
    builder: (context, _) => _MemberState(
      store: _store,
      builder: widget.builder,
      skeleton: widget.skeleton,
    ),
  );
}

class _MemberState extends StatelessWidget {
  const _MemberState({
    required this.store,
    required this.builder,
    required this.skeleton,
  });

  final MemberStore store;
  final Widget Function(BuildContext context, MemberSummary member) builder;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) {
    final member = store.summary;
    if (member != null) return builder(context, member);

    final error = store.error;
    if (error != null) return ErrorView(error: error, onRetry: store.refresh);

    return skeleton ?? const LoadingView();
  }
}
