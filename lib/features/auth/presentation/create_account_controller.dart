import 'package:flutter/widgets.dart';

import '../../../core/security/input_validator.dart';
import '../domain/password_policy.dart';

/// Form state for the create-account screen.
///
/// The password rules come from [PasswordPolicy] so the live chips and the
/// submit guard can never disagree.
class CreateAccountController extends ChangeNotifier {
  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController referralCode = TextEditingController();

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _referralCodeError;

  String? get fullNameError => _fullNameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get referralCodeError => _referralCodeError;

  /// Rules the current password still fails — drives the chips.
  Set<PasswordRule> get unmetRules => PasswordPolicy.unmetRules(password.text);

  void onFullNameChanged(String _) =>
      _clearError(_fullNameError, () => _fullNameError = null);

  void onEmailChanged(String _) =>
      _clearError(_emailError, () => _emailError = null);

  void onReferralCodeChanged(String _) =>
      _clearError(_referralCodeError, () => _referralCodeError = null);

  /// The chips track every keystroke, so this always notifies.
  void onPasswordChanged(String _) {
    _passwordError = null;
    notifyListeners();
  }

  bool validate() {
    _fullNameError = InputValidator.notEmpty(
      InputValidator.sanitize(fullName.text),
      field: 'Full name',
    );
    _emailError = InputValidator.email(InputValidator.sanitize(email.text));
    _passwordError = PasswordPolicy.validate(password.text);
    _referralCodeError = InputValidator.notEmpty(
      InputValidator.sanitize(referralCode.text),
      field: 'Referral code',
    );

    notifyListeners();
    return _fullNameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _referralCodeError == null;
  }

  /// Clears a field's error as soon as the user starts fixing it, and only
  /// then — notifying on every keystroke would rebuild the form for nothing.
  void _clearError(String? current, VoidCallback clear) {
    if (current == null) return;
    clear();
    notifyListeners();
  }

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    password.dispose();
    referralCode.dispose();
    super.dispose();
  }
}
