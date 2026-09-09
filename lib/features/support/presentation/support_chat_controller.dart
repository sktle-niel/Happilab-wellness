import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/security/input_validator.dart';
import '../../../shared/domain/profile_photo.dart';
import '../domain/support_chat.dart';

/// The conversation with support: what has been said and shown, what is
/// being typed, who is on the other end, and the reply that follows each
/// message.
///
/// No support backend yet: the bot answers with the first thing support
/// would ask back, and asking for a person goes through a [SupportDesk] —
/// a free agent joins at once, a busy desk gives a place in line that counts
/// down until one does. The clock and the paces are injected so the thread
/// can be tested without waiting.
class SupportChatController extends ChangeNotifier {
  SupportChatController({
    this._now = DateTime.now,
    SupportDesk? desk,
    this._library,
    this.replyDelay,
    this.linePace = const Duration(seconds: 4),
    this.joinDelay = const Duration(milliseconds: 1500),
  }) : _desk = desk ?? SimulatedSupportDesk() {
    _note(SupportChatCopy.greeting, from: const BotSender());
  }

  /// The beat before a reply, when none is fixed: long enough to be seen
  /// typing, and longer for a longer answer, the way a person would take.
  static const Duration _shortestReply = Duration(milliseconds: 1200);
  static const Duration _longestReply = Duration(seconds: 3);
  static const int _millisecondsPerCharacter = 25;

  final DateTime Function() _now;
  final SupportDesk _desk;

  /// Where a photo to send comes from; null where the platform has none.
  final PhotoLibrary? _library;

  /// How long a reply takes; null lets it depend on the answer.
  final Duration? replyDelay;

  /// How long each place in line takes to clear.
  final Duration linePace;

  /// How long a free agent takes to pick up.
  final Duration joinDelay;

  /// What is being typed. Its own listenable, deliberately: a keystroke
  /// should redraw the send button, not the thread.
  final TextEditingController draft = TextEditingController();

  final List<ChatMessage> _messages = [];
  Handoff _handoff = const NoAgent();
  Timer? _reply;
  Timer? _line;
  int _agentReplies = 0;
  bool _isAttaching = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Handoff get handoff => _handoff;

  bool get canSend => draft.text.trim().isNotEmpty;

  /// True from a message going out until the answer lands.
  bool get isSupportTyping => _reply?.isActive ?? false;

  /// True while a photo is being chosen; the photo button goes inert.
  bool get isAttaching => _isAttaching;

  /// Whoever answers right now: the agent on the line, or the bot.
  ChatSender get responder => switch (_handoff) {
    WithAgent(agent: final agent) => AgentSender(agent),
    NoAgent() || InLine() => const BotSender(),
  };

  /// The agent on the line, when there is one.
  SupportAgent? get agent => switch (_handoff) {
    WithAgent(agent: final agent) => agent,
    NoAgent() || InLine() => null,
  };

  /// Who the header names.
  String get counterpartName => switch (_handoff) {
    WithAgent(agent: final agent) => agent.name,
    NoAgent() || InLine() => SupportChatCopy.agentName,
  };

  /// The line under the name: typing beats everything else.
  String get presenceLine {
    if (isSupportTyping) return SupportChatCopy.typing;
    return switch (_handoff) {
      NoAgent() => SupportChatCopy.status,
      InLine(ahead: 0) => SupportChatCopy.connecting,
      InLine(ahead: final ahead) => SupportChatCopy.inLineStatus(ahead),
      WithAgent() => SupportChatCopy.agentStatus,
    };
  }

  /// Sends what is in the composer, if anything. The agent command is a
  /// request, not a message.
  void sendDraft() {
    final text = InputValidator.sanitize(draft.text);
    if (text.isEmpty) return;
    draft.clear();
    if (text.toLowerCase() == SupportChatCopy.agentCommand) {
      requestAgent();
      return;
    }
    _send(text, botReply: SupportChatCopy.acknowledgement);
  }

  /// Opens the conversation on [topic], in the member's words.
  void choose(SupportTopic topic) =>
      _send(topic.opener, botReply: topic.followUp);

  /// Asks the desk for a person. Nothing happens while one is already on
  /// the way or on the line.
  void requestAgent() {
    if (_handoff is! NoAgent) return;
    _note(SupportChatCopy.requestingAgent);
    final ahead = _desk.queueLength();
    _handoff = InLine(ahead: ahead);
    if (ahead > 0) _note(SupportChatCopy.inLine(ahead));
    _line = Timer(ahead > 0 ? linePace : joinDelay, _advanceLine);
    notifyListeners();
  }

  void _advanceLine() {
    final line = _handoff;
    if (line is! InLine) return;
    final ahead = line.ahead - 1;
    if (ahead <= 0) {
      _join(_desk.nextAgent());
      return;
    }
    _handoff = InLine(ahead: ahead);
    _note(SupportChatCopy.inLine(ahead));
    _line = Timer(linePace, _advanceLine);
  }

  void _join(SupportAgent agent) {
    _handoff = WithAgent(agent);
    _agentReplies = 0;
    _note(SupportChatCopy.joined(agent));
    _reply = Timer(_delayFor(agent.greeting), () => _receive(agent.greeting));
    notifyListeners();
  }

  /// Back to the bot.
  void endAgentChat() {
    final current = _handoff;
    if (current is! WithAgent) return;
    _reply?.cancel();
    _handoff = const NoAgent();
    _note(SupportChatCopy.ended(current.agent));
  }

  /// Opens [source] and sends what the member picks as a photo, when it is
  /// within the limit. Answers the failure for the screen to word — too
  /// heavy, or a source that will not open — or null; backing out is null too.
  Future<AppException?> attachPhoto(PhotoSource source) async {
    final library = _library;
    if (library == null) {
      return const UnknownException(SupportChatCopy.photosUnavailable);
    }
    if (_isAttaching) return null;
    _setAttaching(true);
    final handed = await library.attach(source);
    _setAttaching(false);
    final file = handed.valueOrNull;
    if (file == null) return handed.errorOrNull;
    final bytes = await file.length();
    final refusal = ChatPhoto.validate(bytes);
    if (refusal != null) return ValidationException(refusal);
    _send(
      '',
      botReply: SupportChatCopy.photoAcknowledgement,
      photo: ChatPhoto(file: file, bytes: bytes),
    );
    return null;
  }

  void _setAttaching(bool attaching) {
    _isAttaching = attaching;
    notifyListeners();
  }

  void _send(String text, {required String botReply, ChatPhoto? photo}) {
    _messages.add(
      ChatMessage(
        text: text,
        sentAt: _now(),
        sender: const MemberSender(),
        photo: photo,
      ),
    );
    final reply = switch (_handoff) {
      WithAgent() => _nextAgentReply(),
      NoAgent() || InLine() => botReply,
    };
    _reply?.cancel();
    _reply = Timer(_delayFor(reply), () => _receive(reply));
    notifyListeners();
  }

  String _nextAgentReply() {
    final replies = SupportChatCopy.agentReplies;
    return replies[_agentReplies++ % replies.length];
  }

  void _receive(String text) {
    _messages.add(ChatMessage(text: text, sentAt: _now(), sender: responder));
    notifyListeners();
  }

  void _note(String text, {ChatSender from = const SystemSender()}) {
    _messages.add(ChatMessage(text: text, sentAt: _now(), sender: from));
    notifyListeners();
  }

  Duration _delayFor(String reply) {
    final fixed = replyDelay;
    if (fixed != null) return fixed;
    final typing = Duration(
      milliseconds:
          _shortestReply.inMilliseconds +
          reply.length * _millisecondsPerCharacter,
    );
    return typing > _longestReply ? _longestReply : typing;
  }

  @override
  void dispose() {
    _reply?.cancel();
    _line?.cancel();
    draft.dispose();
    super.dispose();
  }
}
