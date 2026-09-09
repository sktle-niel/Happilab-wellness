import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import 'circle_badge.dart';
import 'gap.dart';
import 'pressable_scale.dart';

/// The line to type into and the disc that sends it — the foot of the
/// support chat and of a comments thread alike.
///
/// Only the send disc follows the draft, keystroke by keystroke; the field
/// and whatever leads it are built once.
class DraftComposer extends StatelessWidget {
  const DraftComposer({
    required this.draft,
    required this.hint,
    required this.onSubmit,
    this.leading,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController draft;
  final String hint;
  final VoidCallback onSubmit;

  /// What sits before the field — the member's avatar on a comments thread.
  final Widget? leading;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (leading != null) ...[leading!, const Gap(10)],
      Expanded(
        child: _DraftField(
          draft: draft,
          hint: hint,
          autofocus: autofocus,
          onSubmit: onSubmit,
        ),
      ),
      const Gap(10),
      ValueListenableBuilder(
        valueListenable: draft,
        builder: (context, value, _) => _SendButton(
          enabled: value.text.trim().isNotEmpty,
          onPressed: onSubmit,
        ),
      ),
    ],
  );
}

class _DraftField extends StatelessWidget {
  const _DraftField({
    required this.draft,
    required this.hint,
    required this.autofocus,
    required this.onSubmit,
  });

  final TextEditingController draft;
  final String hint;
  final bool autofocus;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Container(
    height: AppSpacing.inputHeight,
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: context.palette.glass,
      borderRadius: AppRadius.pill,
      border: Border.all(color: context.palette.glassEdge),
    ),
    child: TextField(
      controller: draft,
      autofocus: autofocus,
      style: AppTypography.input,
      cursorColor: context.palette.accent,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: hint,
        hintStyle: AppTypography.input.copyWith(
          color: context.palette.textFaint,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
      ),
    ),
  );
}

/// The accent disc that sends. Inert while there is nothing to send.
class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    label: 'Send',
    child: PressableScale(
      scale: 0.9,
      onPressed: enabled ? onPressed : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.55,
        duration: AppDuration.fast,
        child: CircleBadge(
          size: AppSpacing.inputHeight,
          color: context.palette.accent,
          child: Icon(
            Icons.send_rounded,
            size: 20,
            color: context.palette.onAccent,
          ),
        ),
      ),
    ),
  );
}
