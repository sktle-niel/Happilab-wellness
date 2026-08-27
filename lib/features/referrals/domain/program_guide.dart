/// One numbered step in the How it works explainer.
class ProgramStep {
  const ProgramStep({
    required this.number,
    required this.title,
    required this.detail,
  });

  final int number;
  final String title;
  final String detail;
}

/// The content of the programme explainer.
///
/// Copy lives in one place so the screen stays layout and the wording can be
/// reviewed without reading Dart.
abstract final class ProgramGuide {
  static const List<ProgramStep> steps = [
    ProgramStep(
      number: 1,
      title: 'Share your code',
      detail:
          'Send your referral code to friends who would like the products. '
          'They enter it when they create their account.',
    ),
    ProgramStep(
      number: 2,
      title: 'They order',
      detail:
          'Every order they place with your code is credited to you — not '
          'just the first one.',
    ),
    ProgramStep(
      number: 3,
      title: 'You earn points',
      detail:
          'Points land in your balance once their order is confirmed, and a '
          'point is a peso when you cash out.',
    ),
  ];

  static const List<String> benefits = [
    'Gentle wellness products made for everyday skin.',
    'Your friend gets the same member pricing you do.',
    'You keep earning on every repeat order they make.',
    'No quota, no joining fee, and no stock to carry.',
  ];

  /// Worked example from the design, kept as data so the numbers are edited in
  /// one place.
  static const String exampleOrder = '₱1,500';
  static const String exampleEarnings = '75–105 points (₱75–₱105)';
}
