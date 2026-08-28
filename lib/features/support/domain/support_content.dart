/// A question and its answer.
class FaqEntry {
  const FaqEntry({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// A titled block of the terms.
class TermsSection {
  const TermsSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

/// Support copy, kept as data so it can be reviewed without reading Dart.
abstract final class SupportContent {
  static const String lastUpdated =
      'Last updated: August 2026 · Falcon Crest Ventures';

  static const List<FaqEntry> faqs = [
    FaqEntry(
      question: 'When do my points appear?',
      answer:
          'Points land once your friend\u2019s order is confirmed, usually '
          'within a day of them checking out.',
    ),
    FaqEntry(
      question: 'How much is a point worth?',
      answer: 'One point is one peso. There is no conversion fee.',
    ),
    FaqEntry(
      question: 'Is there a minimum cash out?',
      answer:
          'Yes — 500 points. You can cash out as often as you like above '
          'that.',
    ),
    FaqEntry(
      question: 'Can I use someone else\u2019s account for payouts?',
      answer:
          'No. The payout account has to be under your own name, which is '
          'how we keep earnings tied to the right member.',
    ),
  ];

  static const List<TermsSection> terms = [
    TermsSection(
      heading: 'Who can join',
      body:
          'Membership is open to anyone in the Philippines aged 18 or over '
          'with a valid referral code.',
    ),
    TermsSection(
      heading: 'How earnings work',
      body:
          'You earn a share of every confirmed order placed with your code. '
          'Cancelled or refunded orders are deducted again.',
    ),
    TermsSection(
      heading: 'Your data',
      body:
          'We store your name, contact details and payout account so we can '
          'pay you. We do not sell your data to anyone.',
    ),
    TermsSection(
      heading: 'Ending your membership',
      body:
          'You can close your account at any time. Points already earned are '
          'paid out before the account closes.',
    ),
  ];
}
