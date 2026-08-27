import '../../../shared/utils/number_format.dart';

/// The rules of a cash out.
abstract final class CashOutTerms {
  static const int minimumPoints = 500;

  /// Preset amounts, plus everything the member has.
  static const List<int> presets = [500, 1000];

  static const String feeNote = 'Minimum cash out: 500 pts · No fees';

  static const String arrivalNote = 'It usually arrives within 24 hours.';
}

/// A past cash out.
class CashOutRecord {
  const CashOutRecord({
    required this.destination,
    required this.when,
    required this.points,
  });

  final String destination;
  final String when;
  final int points;

  String get amountLabel => NumberFormat.peso(points);

  static const List<CashOutRecord> placeholder = [
    CashOutRecord(
      destination: 'GCash · 0917 •••• 1234',
      when: 'Yesterday',
      points: 500,
    ),
    CashOutRecord(
      destination: 'Maya · 0917 •••• 1234',
      when: '12 August',
      points: 1000,
    ),
  ];
}
