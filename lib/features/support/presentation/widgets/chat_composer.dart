import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/profile_photo.dart';
import '../../../../shared/widgets/app_share_sheet.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/draft_composer.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/pressable_scale.dart';
import '../../domain/support_chat.dart';
import '../support_chat_controller.dart';

/// The foot of the thread: one-tap openers for what members write in about,
/// the way to send a photo, and the line to type anything else.
///
/// The line itself is the shared [DraftComposer]; what is this screen's own
/// is the row of chips above it and the photo button before it.
class ChatComposer extends StatelessWidget {
  const ChatComposer({required this.controller, super.key});

  final SupportChatController controller;

  /// A refusal is said in a toast; the draft stays for another try.
  Future<void> _send(BuildContext context) async {
    final overlay = Overlay.of(context);
    final error = await controller.sendDraft();
    if (error != null) AppToast.failureOn(overlay, error);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChipRow(controller: controller),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => DraftComposer(
              leading: _PhotoButton(controller: controller),
              draft: controller.draft,
              hint: controller.isEnded
                  ? SupportChatCopy.endedHint
                  : SupportChatCopy.hint,
              enabled: controller.canType,
              onSubmit: () => _send(context),
            ),
          ),
        ),
      ],
    ),
  );
}

/// One row the thumb swipes through: the topics before anything is sent,
/// the way to a fresh chat once the desk has closed this one, nothing in
/// between. The first and last chips keep the page inset from the edge.
class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.controller});

  final SupportChatController controller;

  /// A refusal is said in a toast, the same as a typed line's.
  Future<void> _choose(BuildContext context, SupportTopic topic) async {
    final overlay = Overlay.of(context);
    final error = await controller.choose(topic);
    if (error != null) AppToast.failureOn(overlay, error);
  }

  List<_ChipSpec> _chips(BuildContext context) => [
    if (controller.isEnded)
      _ChipSpec(
        SupportChatCopy.newChat,
        controller.startNewChat,
        isAccent: true,
      ),
    if (controller.canChooseTopic)
      for (final topic in SupportTopic.values)
        _ChipSpec(topic.label, () => _choose(context, topic)),
  ];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final chips = _chips(context);
      if (chips.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: chips.length,
            separatorBuilder: (context, index) => const Gap.sm(),
            itemBuilder: (context, index) => _Chip(spec: chips[index]),
          ),
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

  /// Drawn in the accent: the one chip that opens a new chat.
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

/// The way to send a picture: a choice of gallery or camera, then the pick
/// goes to the controller, which refuses one over the limit. Inert while a
/// picture is on its way, or while nothing may be sent.
class _PhotoButton extends StatelessWidget {
  const _PhotoButton({required this.controller});

  final SupportChatController controller;

  Future<void> _openSheet(BuildContext context) => AppShareSheet.show(
    context,
    title: SupportChatCopy.sendPhoto,
    note: SupportChatCopy.photoSourceNote,
    targets: [
      ShareTarget.icon(
        label: 'Gallery',
        icon: Icons.photo_library_outlined,
        color: context.palette.accentText,
        onChosen: () => _attach(context, PhotoSource.gallery),
      ),
      ShareTarget.icon(
        label: 'Camera',
        icon: Icons.photo_camera_outlined,
        color: context.palette.accentText,
        onChosen: () => _attach(context, PhotoSource.camera),
      ),
    ],
  );

  /// A refusal — too heavy, a source that will not open, a desk that will
  /// not take it — is said in a toast; backing out says nothing.
  Future<void> _attach(BuildContext context, PhotoSource source) async {
    final overlay = Overlay.of(context);
    final error = await controller.attachPhoto(source);
    if (error != null) AppToast.failureOn(overlay, error);
  }

  bool get _isInert => controller.isAttaching || !controller.canType;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => CircleIconButton(
      icon: Icons.add_photo_alternate_outlined,
      semanticLabel: SupportChatCopy.sendPhoto,
      onPressed: _isInert ? null : () => _openSheet(context),
    ),
  );
}
