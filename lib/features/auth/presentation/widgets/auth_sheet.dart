import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/pressable_scale.dart';
import '../../../../shared/widgets/rise_in.dart';

/// The frame both auth screens share: a sheet risen from the foot of the
/// screen over the app's backdrop, its header and footer pinned and the
/// form scrolling between them. It slides up on arrival while the picture
/// stays put; what the sheet leaves uncovered is the bird.
///
/// Stateful only to own the entrance.
class AuthSheet extends StatefulWidget {
  const AuthSheet({
    required this.title,
    required this.eyebrow,
    required this.heading,
    required this.helper,
    required this.form,
    required this.footer,
    this.progress,
    this.onClose,
    this.closeLabel = 'Close',
    super.key,
  });

  /// The header: what this screen is, and the small line under it.
  final String title;
  final String eyebrow;

  /// How far through the flow this step sits, 0–1. Null draws the plain rule.
  final double? progress;

  /// The corner button. Null on a screen with nowhere to go back to.
  final VoidCallback? onClose;
  final String closeLabel;

  /// The body's opening: what to do here, and a line on how.
  final String heading;
  final String helper;

  /// The form, under the opening.
  final Widget form;

  /// Pinned under the form — see [AuthSheetFooter].
  final Widget footer;

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet>
    with SingleTickerProviderStateMixin {
  /// The most of the screen the sheet may take; the rest shows the picture.
  static const double _maxHeightFraction = 0.9;

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppDuration.entrance,
  )..forward();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    bleedTop: true,
    bleedBottom: true,
    child: LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.bottomCenter,
        child: RiseIn(
          animation: _entrance,
          offset: 48,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight * _maxHeightFraction,
            ),
            child: _Surface(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    title: widget.title,
                    eyebrow: widget.eyebrow,
                    onClose: widget.onClose,
                    closeLabel: widget.closeLabel,
                  ),
                  _StepLine(progress: widget.progress),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                      child: _Body(
                        heading: widget.heading,
                        helper: widget.helper,
                        form: widget.form,
                      ),
                    ),
                  ),
                  _FooterInset(child: widget.footer),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The sheet's foot: Cancel on the left when there is somewhere to cancel
/// to, and [trailing] on the right — the way onward, or a note on it.
class AuthSheetFooter extends StatelessWidget {
  const AuthSheetFooter({required this.trailing, this.onCancel, super.key});

  final Widget trailing;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (onCancel != null)
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: context.palette.textMuted,
          ),
          child: const Text('Cancel'),
        ),
      // Bounded, so a long label wraps at a large font size instead of
      // running off the sheet.
      Expanded(
        child: Align(alignment: Alignment.centerRight, child: trailing),
      ),
    ],
  );
}

/// The glass surface, rounded at the top and flush with the screen's foot.
class _Surface extends StatelessWidget {
  const _Surface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    borderRadius: BorderRadius.vertical(top: AppRadius.hero.topLeft),
    clip: true,
    shadow: context.palette.shadowCard,
    child: child,
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.eyebrow,
    required this.onClose,
    required this.closeLabel,
  });

  final String title;
  final String eyebrow;
  final VoidCallback? onClose;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final onClose = this.onClose;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Gap(2),
                Text(
                  eyebrow,
                  style: AppTypography.screenSubtitle(context.palette),
                ),
              ],
            ),
          ),
          if (onClose != null)
            _CloseButton(label: closeLabel, onPressed: onClose),
        ],
      ),
    );
  }
}

/// A bare cross in the corner, on a full tap target.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: PressableScale(
      scale: 0.9,
      onPressed: onPressed,
      child: SizedBox.square(
        dimension: AppSpacing.iconButtonSize,
        child: Icon(
          Icons.close_rounded,
          size: 22,
          color: context.palette.textPrimary,
        ),
      ),
    ),
  );
}

/// The rule under the header, with the accent run along it as far as the
/// flow has come.
class _StepLine extends StatelessWidget {
  const _StepLine({required this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final progress = this.progress;

    return SizedBox(
      height: 2,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: context.palette.divider)),
          if (progress != null)
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              heightFactor: 1,
              child: ColoredBox(color: context.palette.accent),
            ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.heading,
    required this.helper,
    required this.form,
  });

  final String heading;
  final String helper;
  final Widget form;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(heading, style: AppTypography.screenTitle),
      const Gap(6),
      Text(
        helper,
        style: AppTypography.screenSubtitle(context.palette)
            .copyWith(height: 1.4),
      ),
      const Gap(AppSpacing.lg),
      form,
    ],
  );
}

/// Keeps the footer clear of the gesture bar: the sheet runs to the screen's
/// edge, so the safe inset is paid here.
class _FooterInset extends StatelessWidget {
  const _FooterInset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      12,
      6,
      20,
      10 + MediaQuery.paddingOf(context).bottom,
    ),
    child: child,
  );
}
