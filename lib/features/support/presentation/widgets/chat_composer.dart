import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/circle_badge.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/pressable_scale.dart';
import '../../domain/support_chat.dart';
import '../support_chat_controller.dart';

/// The foot of the thread: one-tap openers for what members write in about,
/// and the line to type anything else.
///
/// Only the send disc follows the draft, keystroke by keystroke; the chips
/// and the field are built once.
class ChatComposer extends StatelessWidget {
  const ChatComposer({required this.controller, super.key});

  final SupportChatController controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChipRow(controller: controller),
        const Gap(10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _DraftField(
                  draft: controller.draft,
                  onSubmit: controller.sendDraft,
                ),
              ),
              const Gap(10),
              ValueListenableBuilder(
                valueListenable: controller.draft,
                builder: (context, _, _) => _SendButton(
                  enabled: controller.canSend,
                  onPressed: controller.sendDraft,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// One row the thumb swipes through: the way to a person, or out of the
/// chat with one, then the topics. The first and last chips keep the page
/// inset from the screen edge.
class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.controller});

  final SupportChatController controller;

  List<_ChipSpec> get _chips => [
    if (controller.handoff is NoAgent)
      _ChipSpec(
        SupportChatCopy.talkToAgent,
        controller.requestAgent,
        isAccent: true,
      ),
    if (controller.handoff is WithAgent)
      _ChipSpec(SupportChatCopy.endChat, controller.endAgentChat),
    for (final topic in SupportTopic.values)
      _ChipSpec(topic.label, () => controller.choose(topic)),
  ];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final chips = _chips;

      return SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: chips.length,
          separatorBuilder: (context, index) => const Gap.sm(),
          itemBuilder: (context, index) => _Chip(spec: chips[index]),
        ),
      );
    },
  );
}

/// What a chip says and does.
class _ChipSpec {
  const _ChipSpec(this.label, this.onPressed, {this.isAccent = false});

  final String label;
  final VoidCallback onPressed;

  /// Drawn in the accent: the one chip that changes who is on the line.
  final bool isAccent;
}

class _Chip extends StatelessWidget {
  const _Chip({required this.spec});

  final _ChipSpec spec;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: PressableScale(
      scale: 0.95,
      onPressed: spec.onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: spec.isAccent ? context.palette.accent : context.palette.glass,
          borderRadius: AppRadius.pill,
          border: spec.isAccent
              ? null
              : Border.all(color: context.palette.glassEdge),
        ),
        child: Text(
          spec.label,
          style: AppTypography.figtree(
            size: 12.5,
            weight: 700,
            color: spec.isAccent ? context.palette.onAccent : null,
          ),
        ),
      ),
    ),
  );
}

class _DraftField extends StatelessWidget {
  const _DraftField({required this.draft, required this.onSubmit});

  final TextEditingController draft;
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
      style: AppTypography.input,
      cursorColor: context.palette.accent,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: 'Type a message… or ${SupportChatCopy.agentCommand}',
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

  VoidCallback? get _onPressed => enabled ? onPressed : null;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    label: 'Send',
    child: PressableScale(
      scale: 0.9,
      onPressed: _onPressed,
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
