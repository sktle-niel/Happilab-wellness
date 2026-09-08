import '../../../shared/domain/program_terms.dart';
import '../../../shared/utils/number_format.dart';

/// The rules of a cash out.
abstract final class CashOutTerms {
  static const int minimumPoints = ProgramTerms.minimumCashOutPoints;

  /// Preset amounts, plus everything the member has.
  static const List<int> presets = [1000, 2000];

  /// The rule, said up front so no one builds up to a cash out they cannot
  /// make yet.
  static String get requirementNote =>
      'You need at least ${NumberFormat.points(minimumPoints)} to cash out. '
      'No fees.';

  /// Stands in for the amounts when the balance cannot be sent yet.
  static String get belowMinimumNote =>
      'You need at least ${NumberFormat.points(minimumPoints)} to cash out.';

  /// Whether [points] can be sent from a balance of [available]: nothing
  /// under the minimum, nothing over what there is. Null when it can.
  static String? validateAmount(int? points, {required int available}) {
    if (points == null) return 'Enter an amount.';
    if (points < minimumPoints) {
      return 'Minimum cash out is ${NumberFormat.points(minimumPoints)}.';
    }
    if (points > available) {
      return 'You only have ${NumberFormat.points(available)}.';
    }
    return null;
  }

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
