import 'package:flutter/widgets.dart';

import '../../../core/errors/app_exception.dart';
import '../../../shared/domain/payout_account.dart';
import '../../../shared/utils/number_format.dart';
import '../domain/cash_out.dart';
import '../domain/rewards_repository.dart';

/// Form state for a cash out: how much, and where to.
///
/// The rules live here so the button's enabled state and the request summary
/// can never disagree with what the screen shows.
class RewardsController extends ChangeNotifier {
  RewardsController({
    required this.availablePoints,
    required this.wallets,
    required this._rewards,
  }) {
    wallets.addListener(_onWalletsChanged);
  }

  final int availablePoints;

  /// The member's saved wallets, which the form follows as they change.
  final PayoutAccounts wallets;

  final RewardsRepository _rewards;

  /// An amount of the member's own, beside the presets.
  final TextEditingController customAmount = TextEditingController();

  int? _amount;
  String? _customAmountError;
  PayoutAccount? _destination;
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  bool _isDisposed = false;

  int? get amount => _amount;
  String? get customAmountError => _customAmountError;
  PayoutAccount? get destination => _destination;

  /// True while the request is with the server; the button goes inert.
  bool get isSubmitting => _isSubmitting;
  bool get isSubmitted => _isSubmitted;

  /// Whether the balance has reached the minimum at all — below it there is
  /// nothing to choose, preset or custom.
  bool get canCashOut => _isSendable(availablePoints);

  /// The wallets the member can send to.
  List<PayoutAccount> get accounts => wallets.all;

  /// The wallets not set up yet, offered for adding beside the list.
  List<PayoutKind> get missingKinds => wallets.missingKinds;

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
    return 'We are sending ${NumberFormat.peso(points)} to your '
        '${account.label} account ${account.reference}.';
  }

  /// A preset: it stands in for whatever was typed.
  void selectAmount(int points) {
    _amount = points;
    _customAmountError = null;
    customAmount.clear();
    notifyListeners();
  }

  /// Typed amounts are checked as they are typed, so the button and the
  /// message under the field never disagree. An emptied field is not an
  /// error, only no choice yet.
  void onCustomAmountChanged(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      _amount = null;
      _customAmountError = null;
      notifyListeners();
      return;
    }
    final points = int.tryParse(digits);
    _customAmountError = CashOutTerms.validateAmount(
      points,
      available: availablePoints,
    );
    _amount = _customAmountError == null ? points : null;
    notifyListeners();
  }

  void selectDestination(PayoutAccount account) {
    _destination = account;
    notifyListeners();
  }

  /// An edit to the chosen wallet keeps it chosen, as edited; a wallet that
  /// is gone is unchosen.
  void _onWalletsChanged() {
    final chosen = _destination;
    if (chosen != null) _destination = wallets.forKind(chosen.kind);
    notifyListeners();
  }

  /// Sends the request. Answers the failure, for the screen to word, or
  /// null once the cash out is on its way.
  Future<AppException?> submit() async {
    if (!canSubmit || _isSubmitting) return null;
    _isSubmitting = true;
    notifyListeners();
    final outcome = await _rewards.requestCashOut(
      points: _amount!,
      to: _destination!,
    );
    if (_isDisposed) return outcome.errorOrNull;
    _isSubmitting = false;
    _isSubmitted = outcome.isSuccess;
    notifyListeners();
    return outcome.errorOrNull;
  }

  /// Back to the form, ready for another request.
  void reset() {
    _isSubmitted = false;
    _amount = null;
    _customAmountError = null;
    customAmount.clear();
    _destination = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    wallets.removeListener(_onWalletsChanged);
    customAmount.dispose();
    super.dispose();
  }
}
