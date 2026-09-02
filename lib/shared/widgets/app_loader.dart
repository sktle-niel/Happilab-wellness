import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import 'gap.dart';

/// Three dots breathing in turn — what the app shows while it waits.
///
/// A rhythm rather than a spinning ring: a spinner still going after six
/// seconds reads as stuck, where a pulse keeps reading as work in progress.
class AppLoader extends StatefulWidget {
  const AppLoader({this.size = 10, super.key});

  /// Diameter of one dot at its fullest.
  final double size;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  static const int _dots = 3;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppDuration.pulse,
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  /// Every dot runs the same curve, each a third of a turn behind the last.
  double _scaleFor(int index) {
    final t = (_pulse.value + index / _dots) % 1;
    // Up for the first half of its turn, back down for the rest.
    final wave = t < 0.5 ? t / 0.5 : (1 - t) / 0.5;
    return 0.55 + 0.45 * Curves.easeInOut.transform(wave);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading',
    child: AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < _dots; index++) ...[
            if (index > 0) SizedBox(width: widget.size * 0.7),
            _Dot(size: widget.size, scale: _scaleFor(index)),
          ],
        ],
      ),
    ),
  );
}

/// One dot. It carries its own opacity so the dot at the back of the wave
/// recedes instead of only shrinking.
class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.scale});

  final double size;
  final double scale;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Center(
      child: Container(
        width: size * scale,
        height: size * scale,
        decoration: BoxDecoration(
          color: context.palette.accentText.withValues(alpha: scale),
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

/// The waiting state a screen shows in place of its content.
///
/// After [AppDuration.slowHint] it admits the wait is long, because a loader
/// that never changes is indistinguishable from one that has hung — and on a
/// weak connection that is exactly when the member starts wondering.
class LoadingView extends StatefulWidget {
  const LoadingView({this.label, super.key});

  /// What is being fetched, when saying so helps.
  final String? label;

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  static const String _slowNote =
      'This is taking longer than usual. Check your connection.';

  Timer? _slowTimer;
  bool _isSlow = false;

  @override
  void initState() {
    super.initState();
    _slowTimer = Timer(AppDuration.slowHint, _admitTheWait);
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  void _admitTheWait() {
    if (!mounted) return;
    setState(() => _isSlow = true);
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoader(),
            if (label != null) ...[
              const Gap(14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.figtree(
                  size: 13.5,
                  weight: 600,
                  color: context.palette.textMuted,
                ),
              ),
            ],
            if (_isSlow) ...[
              const Gap.sm(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Text(
                  _slowNote,
                  textAlign: TextAlign.center,
                  style: AppTypography.figtree(
                    size: 12.5,
                    color: context.palette.textFaint,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
