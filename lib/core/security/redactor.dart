/// Strips secrets out of anything on its way to a log sink.
///
/// Logs are the most common accidental data leak in a mobile app: they end up
/// in crash reports, in `adb logcat`, in support bundles. Nothing reaches a
/// sink without passing through here.
class Redactor {
  const Redactor();

  static const String _mask = '***REDACTED***';

  static final RegExp _bearerToken = RegExp(
    r'bearer\s+[A-Za-z0-9\-._~+/]+=*',
    caseSensitive: false,
  );

  /// `password: hunter2`, `"api_key":"abc"`, `token=abc` — key first, value masked.
  static final RegExp _labelledSecret = RegExp(
    r'''(["']?(?:password|passwd|secret|token|api[_-]?key|authorization|refresh_token)["']?\s*[:=]\s*)["']?[^"',;\s}]+''',
    caseSensitive: false,
  );

  static final RegExp _email = RegExp(
    r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}',
  );

  /// Philippine mobile numbers, in the shapes this app writes them:
  /// `09171234567`, `0917 123 4567`, `+63 917 123 4567`. Eleven digits is one
  /// short of what [_longDigits] catches, and a payout number is the most
  /// sensitive thing the app holds after the token.
  static final RegExp _phoneNumber = RegExp(
    r'(?<!\d)(?:\+?63[\s.-]?|0)9\d{2}[\s.-]?\d{3}[\s.-]?\d{4}(?!\d)',
  );

  /// Long digit runs: card numbers, account numbers, national IDs.
  static final RegExp _longDigits = RegExp(r'\b\d{12,19}\b');

  String redact(String input) => input
      .replaceAll(_bearerToken, 'Bearer $_mask')
      .replaceAllMapped(_labelledSecret, (match) => '${match[1]}$_mask')
      .replaceAll(_email, _mask)
      .replaceAll(_phoneNumber, _mask)
      .replaceAll(_longDigits, _mask);
}
