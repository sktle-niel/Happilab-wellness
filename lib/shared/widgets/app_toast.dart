import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../core/errors/app_exception.dart';
import 'gap.dart';

/// What a toast is telling the member.
enum ToastKind {
  success(Icons.check_circle_outline_rounded),
  info(Icons.info_outline_rounded),
  caution(Icons.warning_amber_rounded),
  error(Icons.error_outline_rounded);

  const ToastKind(this.icon);

  final IconData icon;

  /// The colour that carries the meaning. Each one is a palette entry, so a
  /// toast follows the member into dark mode instead of burning white.
  Color accentOf(AppPalette palette) => switch (this) {
    ToastKind.success => palette.accentText,
    ToastKind.info => palette.info,
    ToastKind.caution => palette.brand,
    ToastKind.error => palette.danger,
  };
}

/// Shows a toast over whatever is on screen.
///
/// It goes through `ScaffoldMessenger` rather than a bare overlay: a second
/// message then replaces the first instead of stacking on it, and the toast
/// withdraws by itself when the screen goes.
abstract final class AppToast {
  static void success(BuildContext context, String title, {String? detail}) =>
      showOn(
        ScaffoldMessenger.of(context),
        ToastKind.success,
        title,
        detail: detail,
      );

  static void info(BuildContext context, String title, {String? detail}) =>
      showOn(
        ScaffoldMessenger.of(context),
        ToastKind.info,
        title,
        detail: detail,
      );

  static void caution(BuildContext context, String title, {String? detail}) =>
      showOn(
        ScaffoldMessenger.of(context),
        ToastKind.caution,
        title,
        detail: detail,
      );

  static void error(BuildContext context, String title, {String? detail}) =>
      showOn(
        ScaffoldMessenger.of(context),
        ToastKind.error,
        title,
        detail: detail,
      );

  /// One-liner for an action that failed: the exception's own user-safe
  /// message under a short headline.
  static void failure(BuildContext context, AppException error) =>
      failureOn(ScaffoldMessenger.of(context), error);

  /// [failure] for a caller already past an `await` — see [showOn].
  ///
  /// Being rate limited is a wait, not a fault, so it lands as a caution.
  static void failureOn(ScaffoldMessengerState messenger, AppException error) {
    final isCooldown = error is RateLimitedException;
    showOn(
      messenger,
      isCooldown ? ToastKind.caution : ToastKind.error,
      isCooldown ? 'One moment' : 'Something went wrong',
      detail: error.message,
    );
  }

  /// For a caller that has already crossed an `await` and can no longer trust
  /// its context: read the messenger before the gap, then hand it here.
  static void showOn(
    ScaffoldMessengerState messenger,
    ToastKind kind,
    String title, {
    String? detail,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: ToastCard(kind: kind, title: title, detail: detail),
          duration: AppDuration.toast,
          // The card draws its own surface and lift; the bar underneath it is
          // only a carrier.
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.all(14),
        ),
      );
  }
}

/// One toast, in the shape the design gives it: a coloured edge, the mark, and
/// the message under its own heading.
class ToastCard extends StatelessWidget {
  const ToastCard({
    required this.kind,
    required this.title,
    this.detail,
    super.key,
  });

  /// Width of the coloured edge the design leads with.
  static const double _edge = 5;

  final ToastKind kind;
  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = kind.accentOf(palette);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.card,
        boxShadow: palette.shadowCard,
      ),
      child: Stack(
        children: [
          Positioned.fill(child: _Wash(accent: accent)),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: _edge,
              child: ColoredBox(color: accent),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(kind.icon, size: 22, color: accent),
                const Gap(12),
                Expanded(
                  child: _Message(title: title, detail: detail),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The tint that bleeds off the coloured edge and clears before the text.
class _Wash extends StatelessWidget {
  const _Wash({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0, 0.75],
        colors: [
          // Heavier in the dark palette: the same wash over a dark surface is
          // almost invisible at the alpha a white one needs.
          accent.withValues(alpha: context.palette.isDark ? 0.22 : 0.13),
          accent.withValues(alpha: 0),
        ],
      ),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final detail = this.detail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTypography.figtree(size: 14.5, weight: 800)),
        if (detail != null) ...[
          const Gap(2),
          Text(
            detail,
            style: AppTypography.figtree(
              size: 13,
              height: 1.4,
              color: context.palette.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
