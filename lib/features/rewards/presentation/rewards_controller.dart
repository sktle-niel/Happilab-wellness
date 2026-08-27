import 'package:flutter/foundation.dart';

import '../../../shared/domain/payout_account.dart';
import '../domain/cash_out.dart';

/// Form state for a cash out: how much, and where to.
///
/// The rules live here so the button's enabled state and the request summary
/// can never disagree with what the screen shows.
class RewardsController extends ChangeNotifier {
  RewardsController({required this.availablePoints});

  final int availablePoints;

  int? _amount;
  PayoutAccount? _destination;
  bool _isSubmitted = false;

  int? get amount => _amount;
  PayoutAccount? get destination => _destination;
  bool get isSubmitted => _isSubmitted;

  /// Presets the member can actually afford, plus their whole balance.
  List<int> get amountOptions => [
    ...CashOutTerms.presets.where((preset) => preset <= availablePoints),
    if (availablePoints > 0 && !CashOutTerms.presets.contains(availablePoints))
      availablePoints,
  ];

  bool get canSubmit =>
      _amount != null &&
      _destination != null &&
      _amount! >= CashOutTerms.minimumPoints &&
      _amount! <= availablePoints;

  /// What the confirmation reads back to the member.
  String get confirmation {
    final account = _destination;
    final points = _amount;
    if (account == null || points == null) return '';
    return 'We are sending ₱$points to your ${account.label} account '
        '${account.reference}.';
  }

  void selectAmount(int points) {
    _amount = points;
    notifyListeners();
  }

  void selectDestination(PayoutAccount account) {
    _destination = account;
    notifyListeners();
  }

  void submit() {
    if (!canSubmit) return;
    _isSubmitted = true;
    notifyListeners();
  }

  /// Back to the form, ready for another request.
  void reset() {
    _isSubmitted = false;
    _amount = null;
    _destination = null;
    notifyListeners();
  }
}
