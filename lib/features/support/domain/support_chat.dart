import 'dart:io';

/// A person on the support desk.
class SupportAgent {
  const SupportAgent(this.name);

  final String name;

  @override
  bool operator ==(Object other) => other is SupportAgent && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

/// Who a line of the conversation came from.
sealed class ChatSender {
  const ChatSender();

  /// Whether two lines belong to one run — the same person, or the same bot.
  bool isSameAs(ChatSender other) => switch ((this, other)) {
    (MemberSender(), MemberSender()) => true,
    (BotSender(), BotSender()) => true,
    (AgentSender(agent: final a), AgentSender(agent: final b)) => a == b,
    _ => false,
  };
}

final class MemberSender extends ChatSender {
  const MemberSender();
}

/// The automatic replies, in the app's own voice.
final class BotSender extends ChatSender {
  const BotSender();
}

final class AgentSender extends ChatSender {
  const AgentSender(this.agent);

  final SupportAgent agent;
}

/// A note about the conversation itself — someone joining, a place in line.
final class SystemSender extends ChatSender {
  const SystemSender();
}

/// A picture in the chat: one just picked on this device, or one the desk
/// holds at an address.
class ChatPhoto {
  const ChatPhoto(this.uri);

  final Uri uri;

  /// True for a picture still on this device — drawn from its file.
  bool get isLocal => uri.isScheme('file');

  File get file => File.fromUri(uri);

  String get url => uri.toString();

  /// The most a photo may weigh. The API refuses anything heavier, so the
  /// check is made here, before a byte leaves the phone.
  static const int maxBytes = 5 * 1024 * 1024;

  static const String limitNote = 'Photos up to 5 MB.';

  /// Null when [bytes] fits under the limit; the sentence the member reads
  /// otherwise.
  static String? validate(int bytes) {
    if (bytes <= maxBytes) return null;
    // Rounded up, so a photo a byte over never reads as exactly 5 MB.
    final megabytes = ((bytes * 10) / (1024 * 1024)).ceil() / 10;
    return 'That photo is ${megabytes.toStringAsFixed(1)} MB; the most is 5 MB.';
  }
}

/// One line of the conversation with support: words, a photo, or both.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.sentAt,
    required this.sender,
    this.id,
    this.photo,
  });

  /// The desk's id for a line it holds; null for what the app says itself.
  final String? id;
  final String text;
  final DateTime sentAt;
  final ChatSender sender;
  final ChatPhoto? photo;

  bool get hasPhoto => photo != null;

  bool get isFromMember => sender is MemberSender;

  bool get isNote => sender is SystemSender;

  /// Whether this and [other] fall in the same minute — the thread shows a
  /// time only where it changes, the way messaging apps group by minute.
  bool sharesMinuteWith(ChatMessage other) =>
      sentAt.year == other.sentAt.year &&
      sentAt.month == other.sentAt.month &&
      sentAt.day == other.sentAt.day &&
      sentAt.hour == other.sentAt.hour &&
      sentAt.minute == other.sentAt.minute;
}

/// Where the conversation stands with the desk.
sealed class Handoff {
  const Handoff();
}

/// Nothing sent yet: the app's greeting and the openers.
final class NoAgent extends Handoff {
  const NoAgent();
}

/// Waiting for a person; [position] is the one-based place in line.
final class InLine extends Handoff {
  const InLine({required this.position});

  final int position;
}

final class WithAgent extends Handoff {
  const WithAgent(this.agent);

  final SupportAgent agent;
}

/// The desk closed the chat; a new one can be opened.
final class ChatEnded extends Handoff {
  const ChatEnded();
}

/// What members most often write in about — offered as one-tap openers so a
/// conversation starts on the right foot, and answered with the first thing
/// support would ask back.
enum SupportTopic {
  account(
    'Account issue',
    'I have a problem with my account.',
    'Sorry about that. What happens when you try — is it signing in, your '
        'details, or something else?',
  ),
  cashOut(
    'Cash out issue',
    'My cash out has a problem.',
    'We will trace it. Which amount and which wallet was it sent to, and '
        'when did you request it?',
  ),
  referral(
    'Referral not counted',
    'A referral of mine was not counted.',
    'Let us check. Who did you refer, and roughly when did they order?',
  ),
  points(
    'Missing points',
    'Some of my points are missing.',
    'We will look into it. Which order are the points from, and on what '
        'date?',
  ),
  payout(
    'Payout account',
    'I need help with my payout account.',
    'Happy to help. Is it GCash or Maya, and what needs changing?',
  ),
  other(
    'Something else',
    'I need help with something else.',
    'Tell us more and we will take it from there.',
  );

  const SupportTopic(this.label, this.opener, this.followUp);

  /// The chip.
  final String label;

  /// What is sent in the member's name when the chip is tapped.
  final String opener;

  /// Support's first question back, in the app's voice, while the desk is
  /// reached.
  final String followUp;
}

/// The lines the app says on its own.
abstract final class SupportChatCopy {
  static const String agentName = 'Falcon Crest Support';
  static const String status = 'Online · replies within 24 hours';
  static const String agentStatus = 'Customer service agent · Online';
  static const String endedStatus = 'Chat ended';
  static const String reconnecting = 'Reconnecting…';
  static const String greeting =
      'Hi! You are chatting with Falcon Crest support. What can we help '
      'you with today?';

  static const String hint = 'Type a message…';
  static const String endedHint = 'This chat has ended';
  static const String newChat = 'Start a new chat';

  static const String sendPhoto = 'Send a photo';
  static const String photoSourceNote =
      'From your gallery or the camera. ${ChatPhoto.limitNote}';
  static const String photosUnavailable = 'Photos cannot be sent from here.';

  static String inLine(int position) =>
      'You are number $position in line. An agent will be with you shortly.';

  static String inLineStatus(int position) => 'Number $position in line';
}
