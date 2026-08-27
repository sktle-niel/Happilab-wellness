import 'package:flutter/widgets.dart';

import '../../../core/security/input_validator.dart';

/// Form state for the sign-in screen.
///
/// The screen renders what this exposes and forwards intents back; every rule
/// lives here, where it can be unit tested without pumping a widget tree.
class SignInController extends ChangeNotifier {
  final TextEditingController identifier = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool _isPasswordHidden = true;
  String? _identifierError;
  String? _passwordError;

  bool get isPasswordHidden => _isPasswordHidden;
  String? get identifierError => _identifierError;
  String? get passwordError => _passwordError;

  void togglePasswordVisibility() {
    _isPasswordHidden = !_isPasswordHidden;
    notifyListeners();
  }

  /// Clears a field's error as soon as the user starts fixing it — leaving it
  /// on screen while they type reads as the app not keeping up.
  void onIdentifierChanged(String _) {
    if (_identifierError == null) return;
    _identifierError = null;
    notifyListeners();
  }

  void onPasswordChanged(String _) {
    if (_passwordError == null) return;
    _passwordError = null;
    notifyListeners();
  }

  /// Returns true when the form is ready to submit.
  bool validate() {
    final value = InputValidator.sanitize(identifier.text);
    _identifierError = value.contains('@')
        ? InputValidator.email(value)
        : InputValidator.notEmpty(value, field: 'Username or Gmail');
    _passwordError = InputValidator.notEmpty(password.text, field: 'Password');

    notifyListeners();
    return _identifierError == null && _passwordError == null;
  }

  @override
  void dispose() {
    identifier.dispose();
    password.dispose();
    super.dispose();
  }
}
