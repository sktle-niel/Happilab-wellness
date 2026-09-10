import 'package:flutter/material.dart';

import '../../../app/di/app_scope.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/avatar_circle.dart';
import '../../../shared/widgets/circle_badge.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/gap.dart';
import '../domain/support_chat.dart';
import 'support_chat_controller.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_thread.dart';
import 'widgets/support_avatar.dart';

/// A conversation with support: the thread, the openers, and the line to
/// type on — with a person from the desk when the member asks for one.
class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  SupportChatController? _controller;

  /// The desk, the chat kept from earlier and the platform's library all
  /// come from the scope, which is not reachable before dependencies are.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final dependencies = AppScope.of(context);
    _controller = SupportChatController(
      desk: dependencies.repositories.supportDesk,
      openChat: dependencies.openChat,
      library: dependencies.photoLibrary,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return AppScaffold(
      child: Column(
        children: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => _ChatHeader(
              name: controller.counterpartName,
              line: controller.presenceLine,
              agent: controller.agent,
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) =>
                  ChatThread(messages: controller.messages),
            ),
          ),
          ChatComposer(controller: controller),
        ],
      ),
    );
  }
}

/// Who the member is talking to — the desk, or the person who picked up —
/// and how they stand.
class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.name,
    required this.line,
    required this.agent,
  });

  final String name;
  final String line;
  final SupportAgent? agent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
    child: Row(
      children: [
        CircleIconButton(
          icon: Icons.arrow_back,
          semanticLabel: 'Back',
          onPressed: Navigator.of(context).pop,
        ),
        const Gap(12),
        _CounterpartAvatar(agent: agent),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: AppTypography.figtree(size: 16, weight: 800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              _Presence(line: line),
            ],
          ),
        ),
      ],
    ),
  );
}

/// The app's face for the desk; a person's initials once one has joined.
class _CounterpartAvatar extends StatelessWidget {
  const _CounterpartAvatar({required this.agent});

  static const double _size = 44;

  final SupportAgent? agent;

  @override
  Widget build(BuildContext context) {
    final agent = this.agent;
    if (agent == null) return const SupportAvatar(size: _size);
    return AvatarCircle(name: agent.name, size: _size, bordered: true);
  }
}

/// A green dot and the line under the name, which cross-fades as it
/// changes — online, a place in line, an agent, the end.
class _Presence extends StatelessWidget {
  const _Presence({required this.line});

  final String line;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleBadge(
        size: 8,
        color: context.palette.accent,
        child: const SizedBox.shrink(),
      ),
      const Gap(6),
      Flexible(
        child: AnimatedSwitcher(
          duration: AppDuration.fast,
          child: Text(
            line,
            key: ValueKey(line),
            style: AppTypography.figtree(
              size: 12.5,
              color: context.palette.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
  );
}
