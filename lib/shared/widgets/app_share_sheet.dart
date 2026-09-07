import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import 'app_card.dart';
import 'gap.dart';
import 'pressable_scale.dart';
import '../../app/theme/app_palette.dart';

/// One destination on a share sheet: the disc, its name, and what choosing
/// it does.
class ShareTarget {
  const ShareTarget({
    required this.label,
    required this.child,
    required this.onChosen,
  });

  /// A target wearing an app's own icon, full bleed, the way it sits on a
  /// phone's home screen.
  ShareTarget.appLogo({
    required this.label,
    required String asset,
    required this.onChosen,
  }) : child = Image.asset(asset, fit: BoxFit.cover, cacheWidth: 174);

  /// A target wearing one of our own glyphs on the tint disc — copy, post,
  /// story: the actions that belong to this app rather than another.
  ShareTarget.icon({
    required this.label,
    required IconData icon,
    required Color color,
    required this.onChosen,
  }) : child = Icon(icon, size: 24, color: color);

  final String label;

  /// What fills the disc — a logo drawn full bleed, or an icon.
  final Widget child;

  /// Runs after the sheet has closed, through the caller's own context.
  final VoidCallback onChosen;
}

/// The share sheet every share in the app opens: a handle, a heading, a row
/// of round targets, and cancel.
///
/// Every choice closes the sheet first and then acts through the caller's
/// context, so a snackbar has a live scaffold to land on.
class AppShareSheet extends StatelessWidget {
  const AppShareSheet({
    required this.title,
    required this.targets,
    this.note,
    this.preview,
    super.key,
  });

  final String title;
  final String? note;

  /// Shown between the heading and the targets — the invite sheet puts the
  /// message being sent here, so the member reads it before choosing where.
  final Widget? preview;
  final List<ShareTarget> targets;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<ShareTarget> targets,
    String? note,
    Widget? preview,
  }) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    // Sized by its content, not the default 9/16 cap — a preview plus a row
    // of targets is taller than the cap allows.
    isScrollControlled: true,
    builder: (_) => AppShareSheet(
      title: title,
      note: note,
      preview: preview,
      targets: targets,
    ),
  );

  void _choose(BuildContext context, ShareTarget target) {
    Navigator.of(context).pop();
    target.onChosen();
  }

  @override
  Widget build(BuildContext context) {
    final note = this.note;
    final preview = this.preview;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          shadow: context.palette.shadowCard,
          // Scrolls only when a short screen makes it: the sheet is normally
          // exactly as tall as its content.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Handle(),
                const Gap(14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.figtree(size: 17, weight: 800),
                ),
                if (note != null) ...[
                  const Gap(4),
                  Text(
                    note,
                    textAlign: TextAlign.center,
                    style: AppTypography.figtree(
                      size: 12.5,
                      color: context.palette.textMuted,
                    ),
                  ),
                ],
                if (preview != null) ...[const Gap(14), preview],
                const Gap(20),
                // One line the thumb swipes through, the way the platform's own
                // share sheets scroll — a target cut off at the edge is the cue
                // that more follow. Centred when the few that exist all fit.
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final target in targets) ...[
                          if (target != targets.first) const Gap(14),
                          _TargetButton(
                            target: target,
                            onPressed: () => _choose(context, target),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Gap(20),
                _CancelButton(onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: context.palette.divider,
      borderRadius: AppRadius.pill,
    ),
  );
}

/// A round target with its name beneath — a logo or an icon, same footprint.
///
/// Every target claims the same width, so the swiping line stays on a grid
/// and a long name trims instead of shoving its neighbours.
class _TargetButton extends StatelessWidget {
  const _TargetButton({required this.target, required this.onPressed});

  static const double _size = 58;
  static const double _slotWidth = 64;

  final ShareTarget target;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: target.label,
    child: PressableScale(
      scale: 0.92,
      onPressed: onPressed,
      child: SizedBox(
        width: _slotWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _size,
              height: _size,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.palette.tint,
                shape: BoxShape.circle,
              ),
              // Drawn over the child so a full-bleed icon still gets the ring.
              foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.palette.divider),
              ),
              alignment: Alignment.center,
              child: target.child,
            ),
            const Gap(8),
            Text(
              target.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.figtree(size: 12, weight: 700),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: PressableScale(
      onPressed: onPressed,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.palette.tint,
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          'Cancel',
          style: AppTypography.figtree(
            size: 15,
            weight: 700,
            color: context.palette.accentText,
          ),
        ),
      ),
    ),
  );
}
