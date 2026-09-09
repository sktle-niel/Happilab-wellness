import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/domain/member_summary.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/arrival.dart';
import '../../../../shared/widgets/avatar_circle.dart';
import '../../../../shared/widgets/gap.dart';
import '../../../../shared/widgets/member_avatar.dart';
import '../../domain/support_chat.dart';
import 'support_avatar.dart';

/// One message in the thread: support's on the left in glass, the member's
/// on the right in the accent, each with its sender's face beside it on the
/// last message of a run.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    required this.showsAvatar,
    super.key,
  });

  final ChatMessage message;

  /// True on the message that closes a run from one sender; the others in
  /// the run leave the slot empty so the bubbles still line up.
  final bool showsAvatar;

  @override
  Widget build(BuildContext context) => _BubbleRow(
    sender: message.sender,
    showsAvatar: showsAvatar,
    tight: message.hasPhoto,
    child: _Content(message: message),
  );
}

/// What a bubble holds: the photo, the words, or both, one under the other.
class _Content extends StatelessWidget {
  const _Content({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final photo = message.photo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photo != null) _Photo(photo: photo),
        if (message.text.isNotEmpty)
          Padding(
            padding: photo == null
                ? EdgeInsets.zero
                : const EdgeInsets.fromLTRB(8, 8, 8, 2),
            child: Text(
              message.text,
              style: AppTypography.figtree(
                size: 14,
                height: 1.4,
                color: message.isFromMember
                    ? context.palette.onAccent
                    : context.palette.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

/// The picture, a square no wider than a bubble, clipped to its corners.
/// One that will not read any more shows a broken frame, never a crash.
class _Photo extends StatelessWidget {
  const _Photo({required this.photo});

  static const double _edge = 220;

  final ChatPhoto photo;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadius.input,
    child: Image.file(
      photo.file,
      width: _edge,
      height: _edge,
      fit: BoxFit.cover,
      cacheWidth: (_edge * 3).round(),
      errorBuilder: (context, error, stackTrace) => const _MissingPhoto(),
    ),
  );
}

class _MissingPhoto extends StatelessWidget {
  const _MissingPhoto();

  @override
  Widget build(BuildContext context) => Container(
    width: _Photo._edge,
    height: _Photo._edge,
    alignment: Alignment.center,
    color: context.palette.glass,
    child: Icon(Icons.broken_image_outlined, color: context.palette.textMuted),
  );
}

/// Whoever is answering, mid-reply: the loader's dots in their bubble.
class TypingBubble extends StatelessWidget {
  const TypingBubble({required this.sender, super.key});

  final ChatSender sender;

  @override
  Widget build(BuildContext context) => _BubbleRow(
    sender: sender,
    showsAvatar: true,
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: AppLoader(size: 7),
    ),
  );
}

/// A note about the conversation itself, small and in the middle: someone
/// joining, a place in line.
class SystemNote extends StatelessWidget {
  const SystemNote({required this.text, super.key});

  @override
  Widget build(BuildContext context) => Arrival(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.figtree(
          size: 12,
          weight: 600,
          height: 1.4,
          color: context.palette.textMuted,
        ),
      ),
    ),
  );

  final String text;
}

/// The bubble with its avatar slot: face, gap, bubble for support; bubble,
/// gap, face for the member — mirrored, and pushed to their own side. It
/// rises in as it lands.
class _BubbleRow extends StatelessWidget {
  const _BubbleRow({
    required this.sender,
    required this.showsAvatar,
    required this.child,
    this.tight = false,
  });

  /// How much of the width a bubble may take before it wraps.
  static const double _widthFactor = 0.74;

  final ChatSender sender;
  final bool showsAvatar;
  final Widget child;

  /// True for a photo, which sits close to the bubble's edge.
  final bool tight;

  bool get fromMember => sender is MemberSender;

  @override
  Widget build(BuildContext context) => Arrival(
    // Laid out right-to-left for the member, so "start" is the right edge:
    // face first, then the bubble, packed against that edge.
    child: Row(
      textDirection: fromMember ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _AvatarSlot(sender: sender, isShown: showsAvatar),
        const Gap.sm(),
        Flexible(
          child: FractionallySizedBox(
            widthFactor: _widthFactor,
            child: Align(
              alignment: fromMember
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: _Bubble(
                fromMember: fromMember,
                tight: tight,
                child: child,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// The sender's face, or the space it would take: the member's own picture,
/// the app's icon for the bot, an agent's initials.
class _AvatarSlot extends StatelessWidget {
  const _AvatarSlot({required this.sender, required this.isShown});

  static const double _size = 28;

  final ChatSender sender;
  final bool isShown;

  @override
  Widget build(BuildContext context) {
    if (!isShown) return const SizedBox.square(dimension: _size);
    return switch (sender) {
      MemberSender() => MemberAvatar(
        photo: AppScope.of(context).profilePhoto,
        name: MemberSummary.placeholder.name,
        size: _size,
      ),
      AgentSender(agent: final agent) => AvatarCircle(
        name: agent.name,
        size: _size,
      ),
      BotSender() || SystemSender() => const SupportAvatar(size: _size),
    };
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.fromMember,
    required this.tight,
    required this.child,
  });

  final bool fromMember;
  final bool tight;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 3),
    padding: tight
        ? const EdgeInsets.all(6)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: fromMember ? context.palette.accent : context.palette.glass,
      borderRadius: AppRadius.input,
      border: fromMember ? null : Border.all(color: context.palette.glassEdge),
    ),
    child: child,
  );
}

/// The minute a run of messages was sent, small and above them, on the
/// sender's side.
class TimeLabel extends StatelessWidget {
  const TimeLabel({required this.time, required this.atEnd, super.key});

  final DateTime time;

  /// True on the member's side — the right.
  final bool atEnd;

  @override
  Widget build(BuildContext context) => Align(
    alignment: atEnd ? Alignment.centerRight : Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Text(
        DateFormat.time(time),
        style: AppTypography.figtree(
          size: 11.5,
          weight: 700,
          color: context.palette.textFaint,
        ),
      ),
    ),
  );
}

/// The day the thread below it belongs to, on a small pill in the middle.
class DayPill extends StatelessWidget {
  const DayPill({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: context.palette.glass,
        borderRadius: AppRadius.pill,
        border: Border.all(color: context.palette.glassEdge),
      ),
      child: Text(
        label,
        style: AppTypography.figtree(
          size: 11.5,
          weight: 700,
          color: context.palette.textMuted,
        ),
      ),
    ),
  );
}
