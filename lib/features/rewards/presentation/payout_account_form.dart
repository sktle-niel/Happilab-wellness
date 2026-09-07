import 'package:flutter/widgets.dart';

import '../../../core/security/input_validator.dart';
import '../../../shared/domain/payout_account.dart';

/// Form state for one payout wallet: the name on the account and its number.
///
/// Opens on what is already saved for the wallet, when anything is, so the
/// same form adds and edits. The rules live here and in [PayoutAccount], so
/// the screen only renders them.
class PayoutAccountForm extends ChangeNotifier {
  PayoutAccountForm({required this.kind, PayoutAccount? existing})
    : isNew = existing == null,
      accountName = TextEditingController(text: existing?.accountName),
      number = TextEditingController(text: existing?.number);

  final PayoutKind kind;

  /// True when there is no account for this wallet yet.
  final bool isNew;

  final TextEditingController accountName;
  final TextEditingController number;

  String? _accountNameError;
  String? _numberError;

  String? get accountNameError => _accountNameError;
  String? get numberError => _numberError;

  void onAccountNameChanged(String _) =>
      _clearError(_accountNameError, () => _accountNameError = null);

  void onNumberChanged(String _) =>
      _clearError(_numberError, () => _numberError = null);

  /// The account the form describes, once it is complete — or null, with the
  /// errors set for the screen to show.
  PayoutAccount? submit() {
    final name = InputValidator.sanitize(accountName.text);
    // Spaces and dashes are how people type a number, not part of it.
    final digits = InputValidator.sanitize(number.text)
        .replaceAll(RegExp(r'\D'), '');

    _accountNameError = InputValidator.notEmpty(name, field: 'Account name');
    _numberError = PayoutAccount.validateNumber(digits);
    notifyListeners();

    if (_accountNameError != null || _numberError != null) return null;
    return PayoutAccount(kind: kind, accountName: name, number: digits);
  }

  /// Clears a field's error as soon as the member starts fixing it, and only
  /// then — notifying on every keystroke would rebuild the form for nothing.
  void _clearError(String? current, VoidCallback clear) {
    if (current == null) return;
    clear();
    notifyListeners();
  }

  @override
  void dispose() {
    accountName.dispose();
    number.dispose();
    super.dispose();
  }
}
