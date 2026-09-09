import 'dart:io';
import 'dart:math';

/// A person on the support desk.
class SupportAgent {
  const SupportAgent(this.name);

  final String name;

  String get greeting =>
      'Hi, I am $name from Falcon Crest support. I have read the thread — '
      'how can I help?';

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

/// A picture sent in the chat, as it sits on this device.
class ChatPhoto {
  const ChatPhoto({required this.file, required this.bytes});

  final File file;
  final int bytes;

  /// The most a photo may weigh. The API refuses anything heavier, so the
  /// check is made here, before a byte leaves the phone.
  static const int maxBytes = 5 * 1024 * 1024;

  static const String limitNote = 'Photos up to 5 MB.';

  /// Null when [bytes] fits under the limit; the sentence the member reads
  /// otherwise.
  static String? validate(int bytes) {
    if (bytes <= maxBytes) return null;
    final megabytes = (bytes / (1024 * 1024)).toStringAsFixed(1);
    return 'That photo is $megabytes MB; the most is 5 MB.';
  }
}

/// One line of the conversation with support: words, a photo, or both.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.sentAt,
    required this.sender,
    this.photo,
  });

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

/// Talking to the bot.
final class NoAgent extends Handoff {
  const NoAgent();
}

/// Waiting for a person; [ahead] is how many members are before us.
final class InLine extends Handoff {
  const InLine({required this.ahead});

  final int ahead;
}

final class WithAgent extends Handoff {
  const WithAgent(this.agent);

  final SupportAgent agent;
}

/// The desk: how long the line is right now, and who picks up next.
abstract interface class SupportDesk {
  /// Members ahead in line; zero means an agent is free this moment.
  int queueLength();

  SupportAgent nextAgent();
}

/// Stands in for the real desk until there is one: a short line as often as
/// none, and one of a few names.
class SimulatedSupportDesk implements SupportDesk {
  SimulatedSupportDesk({Random? random}) : _random = random ?? Random();

  static const List<SupportAgent> _agents = [
    SupportAgent('Maria'),
    SupportAgent('Paolo'),
    SupportAgent('Jen'),
  ];

  /// The line is never longer than this.
  static const int _longestLine = 3;

  final Random _random;

  @override
  int queueLength() => _random.nextInt(_longestLine + 1);

  @override
  SupportAgent nextAgent() => _agents[_random.nextInt(_agents.length)];
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

  /// Support's first question back.
  final String followUp;
}

/// The lines the app says on its own, and the ways in to a person.
abstract final class SupportChatCopy {
  static const String agentName = 'Falcon Crest Support';
  static const String status = 'Online · replies within 24 hours';
  static const String typing = 'typing…';
  static const String agentStatus = 'Customer service agent · Online';
  static const String connecting = 'Connecting…';
  static const String greeting =
      'Hi! You are chatting with Falcon Crest support. What can we help '
      'you with today?';

  /// The answer to a message typed freely, until a person picks it up.
  static const String acknowledgement =
      'Thanks, we have got it. A teammate will reply here within 24 hours.';

  /// The answer to a photo, until a person picks it up.
  static const String photoAcknowledgement =
      'Got the photo, thanks. A teammate will take a look.';

  static const String sendPhoto = 'Send a photo';
  static const String photoSourceNote =
      'From your gallery or the camera. ${ChatPhoto.limitNote}';
  static const String photosUnavailable = 'Photos cannot be sent from here.';

  /// Typed into the composer, this asks for a person.
  static const String agentCommand = '/agent';
  static const String talkToAgent = 'Talk to an agent';
  static const String endChat = 'End chat';
  static const String requestingAgent =
      'Connecting you to a customer service agent…';

  static String inLine(int ahead) =>
      'You are number $ahead in line. An agent will be with you shortly.';

  static String inLineStatus(int ahead) => 'Number $ahead in line';

  static String joined(SupportAgent agent) =>
      '${agent.name} has joined the chat.';

  static String ended(SupportAgent agent) =>
      'Chat with ${agent.name} has ended. We are here if you need us again.';

  /// What an agent says while a real answer is being worked out, in turn.
  static const List<String> agentReplies = [
    'Got it — let me check that for you.',
    'Thanks, one moment while I look into it.',
    'Understood, I am on it. I will be right back with an answer.',
  ];
}
