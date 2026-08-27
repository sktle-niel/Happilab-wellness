/// Validation and sanitising for anything the user types.
///
/// Input is untrusted by definition: it is checked on the device to fail fast,
/// and checked again on the server because a client check is a courtesy, not a
/// security control.
abstract final class InputValidator {
  static final RegExp _email = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$',
  );

  /// Control characters can corrupt logs and downstream parsers — drop them.
  static final RegExp _controlCharacters = RegExp(r'[\u0000-\u001F\u007F]');

  /// Returns `null` when valid, matching Flutter's `FormFieldValidator` shape.
  static String? notEmpty(String? value, {String field = 'This field'}) =>
      (value == null || value.trim().isEmpty) ? '$field is required.' : null;

  static String? email(String? value) {
    final empty = notEmpty(value, field: 'Email');
    if (empty != null) return empty;
    return _email.hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address.';
  }

  static String? minLength(
    String? value,
    int length, {
    String field = 'This field',
  }) {
    final empty = notEmpty(value, field: field);
    if (empty != null) return empty;
    return value!.trim().length >= length
        ? null
        : '$field must be at least $length characters.';
  }

  /// Trims, removes control characters and caps length so a paste bomb cannot
  /// travel any further into the app.
  static String sanitize(String value, {int maxLength = 512}) {
    final cleaned = value.replaceAll(_controlCharacters, '').trim();
    return cleaned.length <= maxLength
        ? cleaned
        : cleaned.substring(0, maxLength);
  }
}
