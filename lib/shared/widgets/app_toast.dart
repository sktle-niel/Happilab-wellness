import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../core/errors/app_exception.dart';
import 'circle_badge.dart';
import 'gap.dart';

/// What a toast is telling the member.
enum ToastKind {
  success(Icons.check_rounded),
  info(Icons.info_outline_rounded),
  caution(Icons.priority_high_rounded),
  error(Icons.close_rounded);

  /// The glyph drawn in white inside the badge disc.
  const ToastKind(this.icon);

  final IconData icon;

  /// The disc colour that carries the meaning. Palette entries, so the badge
  /// follows the member into dark mode.
  Color accentOf(AppPalette palette) => switch (this) {
    ToastKind.success => palette.accent,
    ToastKind.info => palette.info,
    ToastKind.caution => palette.brand,
    ToastKind.error => palette.danger,
  };

  /// The glyph's own colour on that disc — dark on the bright brand lime,
  /// white on everything else.
  Color glyphOf(AppPalette palette) => switch (this) {
    ToastKind.success => palette.onAccent,
    _ => Colors.white,
  };
}

/// Shows a toast over whatever is on screen, dropping in from the top — where
/// the eye already is — instead of fighting the nav bar at the bottom, which
/// is as high as a `SnackBar` can ever rise.
///
/// Drawn straight onto the app's [Overlay]. Messages stack the way modern
/// toasts do: the newest lands in front and the ones before it peek out from
/// behind, nudged down and scaled back, three deep at most. Each toast keeps
/// its own clock and takes itself down; a tap dismisses one early.
abstract final class AppToast {
  /// How many toasts stand in the stack before the oldest is let go.
  static const int _maxStacked = 3;

  /// The standing toasts, oldest first. Module state rather than a service: a
  /// toast is fire-and-forget chrome, and threading a controller through
  /// every screen for it would be ceremony.
  static final ValueNotifier<List<_Toast>> _toasts = ValueNotifier(<_Toast>[]);

  static OverlayEntry? _host;
  static int _ids = 0;

  static void success(BuildContext context, String title, {String? detail}) =>
      showOn(Overlay.of(context), ToastKind.success, title, detail: detail);

  static void info(BuildContext context, String title, {String? detail}) =>
      showOn(Overlay.of(context), ToastKind.info, title, detail: detail);

  static void caution(BuildContext context, String title, {String? detail}) =>
      showOn(Overlay.of(context), ToastKind.caution, title, detail: detail);

  static void error(BuildContext context, String title, {String? detail}) =>
      showOn(Overlay.of(context), ToastKind.error, title, detail: detail);

  /// One-liner for surfacing a failed action: the exception's own user-safe
  /// message under a short headline.
  static void failure(BuildContext context, AppException error) =>
      failureOn(Overlay.of(context), error);

  /// [failure] for a caller already past an `await` — see [showOn].
  ///
  /// Being rate limited is a wait, not a fault, so it lands as a caution.
  static void failureOn(OverlayState overlay, AppException error) {
    final isCooldown = error is RateLimitedException;
    showOn(
      overlay,
      isCooldown ? ToastKind.caution : ToastKind.error,
      isCooldown ? 'One moment' : 'Something went wrong',
      detail: error.message,
    );
  }

  /// For a caller that has already crossed an `await` and can no longer trust
  /// its context: read `Overlay.of(context)` before the gap, then hand it
  /// here.
  static void showOn(
    OverlayState overlay,
    ToastKind kind,
    String title, {
    String? detail,
  }) {
    final toast = _Toast(id: _ids++, kind: kind, title: title, detail: detail);

    if (_host == null || !(_host!.mounted)) {
      // A fresh overlay (first toast, or a new app root) starts a fresh stack.
      _toasts.value = [toast];
      _host = OverlayEntry(
        builder: (_) => _ToastStack(toasts: _toasts, onDone: _remove),
      );
      overlay.insert(_host!);
      return;
    }

    final next = [..._toasts.value, toast];
    _toasts.value = next.length > _maxStacked
        ? next.sublist(next.length - _maxStacked)
        : next;
  }

  static void _remove(_Toast toast) {
    _toasts.value = [
      for (final standing in _toasts.value)
        if (!identical(standing, toast)) standing,
    ];
  }
}

/// One message and its identity in the stack.
class _Toast {
  const _Toast({
    required this.id,
    required this.kind,
    required this.title,
    required this.detail,
  });

  final int id;
  final ToastKind kind;
  final String title;
  final String? detail;
}

/// The stack itself: newest card in front, the ones before it peeking out
/// behind, everything anchored under the status bar.
class _ToastStack extends StatelessWidget {
  const _ToastStack({required this.toasts, required this.onDone});

  final ValueListenable<List<_Toast>> toasts;
  final void Function(_Toast toast) onDone;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    // Text drawn on a bare overlay has no Material above it and grows the
    // debug underline; the transparent sheet is what keeps it plain.
    child: Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: ValueListenableBuilder<List<_Toast>>(
              valueListenable: toasts,
              builder: (context, standing, _) => Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Painted oldest first, so the newest lands on top.
                  for (final (index, toast) in standing.indexed)
                    _StackedToast(
                      key: ValueKey(toast.id),
                      toast: toast,
                      depth: standing.length - 1 - index,
                      onDone: () => onDone(toast),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// One toast's stay in the stack: drop in from the top, slide back as newer
/// ones land in front, fade, and take itself down. A tap hurries it along.
class _StackedToast extends StatefulWidget {
  const _StackedToast({
    required this.toast,
    required this.depth,
    required this.onDone,
    super.key,
  });

  final _Toast toast;

  /// How many newer toasts stand in front: 0 is the front card.
  final int depth;

  final VoidCallback onDone;

  @override
  State<_StackedToast> createState() => _StackedToastState();
}

class _StackedToastState extends State<_StackedToast>
    with SingleTickerProviderStateMixin {
  /// Entrance and exit, as fractions of the whole life.
  static const double _in = 0.08;
  static const double _out = 0.92;

  /// How far above its resting place the card drops in from.
  static const double _drop = 14;

  /// How far down, and how much smaller, each step back in the stack sits.
  static const double _stackShift = 12;
  static const double _stackShrink = 0.05;

  late final AnimationController _life =
      AnimationController(vsync: this, duration: AppDuration.toast)
        ..addStatusListener(_onStatus)
        ..forward();

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onDone();
  }

  /// Rushes the remaining life into a quick fade instead of vanishing.
  void _dismissEarly() {
    if (_life.value >= _out) return;
    _life.animateTo(1, duration: AppDuration.fast);
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  double _opacityAt(double t) {
    if (t < _in) return t / _in;
    if (t > _out) return (1 - t) / (1 - _out);
    return 1;
  }

  double _riseAt(double t) =>
      t >= _in ? 0 : -_drop * (1 - Curves.easeOutCubic.transform(t / _in));

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    // Eases to its place in the stack as newer toasts land in front.
    tween: Tween(end: widget.depth.toDouble()),
    duration: AppDuration.screenIn,
    curve: Curves.easeOutCubic,
    builder: (context, depth, child) => Transform.translate(
      offset: Offset(0, depth * _stackShift),
      child: Transform.scale(
        scale: 1 - depth * _stackShrink,
        alignment: Alignment.topCenter,
        child: child,
      ),
    ),
    child: AnimatedBuilder(
      animation: _life,
      builder: (context, child) => Opacity(
        opacity: _opacityAt(_life.value).clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, _riseAt(_life.value)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: _dismissEarly,
        // As wide as its words and no wider — a short message makes a small
        // card, and a long one wraps instead of spanning the screen.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: ToastCard(
            kind: widget.toast.kind,
            title: widget.toast.title,
            detail: widget.toast.detail,
          ),
        ),
      ),
    ),
  );
}

/// One toast, in the pop-up notification shape: the theme's own surface with
/// a solid badge disc carrying the meaning — light card in the light theme,
/// dark card in the dark one. A tap anywhere on it dismisses it.
class ToastCard extends StatelessWidget {
  const ToastCard({
    required this.kind,
    required this.title,
    this.detail,
    super.key,
  });

  final ToastKind kind;
  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.input,
        boxShadow: palette.shadowCard,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // No taller than the title's own line, so the badge reads as part
          // of the sentence rather than an ornament beside it.
          CircleBadge(
            size: 16,
            color: kind.accentOf(palette),
            child: Icon(kind.icon, size: 11, color: kind.glyphOf(palette)),
          ),
          const Gap(8),
          Flexible(
            child: _Message(title: title, detail: detail),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final detail = this.detail;
    // Plain ink, no greys: near-black on the light card, near-white on the
    // dark one.
    final ink = context.palette.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.figtree(size: 14.5, weight: 700, color: ink),
        ),
        if (detail != null) ...[
          const Gap(2),
          Text(
            detail,
            style: AppTypography.figtree(size: 13, height: 1.4, color: ink),
          ),
        ],
      ],
    );
  }
}
