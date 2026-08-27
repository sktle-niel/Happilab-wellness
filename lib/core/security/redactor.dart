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

  /// Long digit runs: card numbers, account numbers, national IDs.
  static final RegExp _longDigits = RegExp(r'\b\d{12,19}\b');

  String redact(String input) => input
      .replaceAll(_bearerToken, 'Bearer $_mask')
      .replaceAllMapped(_labelledSecret, (match) => '${match[1]}$_mask')
      .replaceAll(_email, _mask)
      .replaceAll(_longDigits, _mask);
}
