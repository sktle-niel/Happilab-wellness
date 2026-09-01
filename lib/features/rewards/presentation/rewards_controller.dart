import 'package:flutter/foundation.dart';

import '../../../shared/domain/payout_account.dart';
import '../domain/cash_out.dart';

/// Form state for a cash out: how much, and where to.
///
/// The rules live here so the button's enabled state and the request summary
/// can never disagree with what the screen shows.
class RewardsController extends ChangeNotifier {
  RewardsController({
    required this.availablePoints,
    this.accounts = PayoutAccount.placeholder,
  });

  final int availablePoints;

  /// The wallets the member can send to.
  final List<PayoutAccount> accounts;

  int? _amount;
  PayoutAccount? _destination;
  bool _isSubmitted = false;

  int? get amount => _amount;
  PayoutAccount? get destination => _destination;
  bool get isSubmitted => _isSubmitted;

  /// The presets the member can send, plus their whole balance.
  ///
  /// Offering an amount the form would then refuse leaves the member tapping a
  /// chip that never enables the button, so both sides ask [_isSendable].
  List<int> get amountOptions => [
    ...CashOutTerms.presets.where(_isSendable),
    if (_isSendable(availablePoints) &&
        !CashOutTerms.presets.contains(availablePoints))
      availablePoints,
  ];

  bool get canSubmit =>
      _amount != null && _destination != null && _isSendable(_amount!);

  bool _isSendable(int points) =>
      points >= CashOutTerms.minimumPoints && points <= availablePoints;

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
