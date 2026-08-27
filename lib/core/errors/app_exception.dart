/// Every failure the app can show a user, as a closed set.
///
/// Sealed so `switch` over a failure is exhaustive — a new failure type cannot
/// be added without the compiler pointing at the places that must handle it.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Safe to display: never contains tokens, payloads or stack traces.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No usable connection, DNS failure, TLS failure.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

final class RequestTimeoutException extends AppException {
  const RequestTimeoutException([super.message = 'The request timed out.']);
}

/// 401/403 — the session is gone or the caller lacks permission.
final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Please sign in again.']);
}

/// 429, or the client-side limiter refusing to send.
final class RateLimitedException extends AppException {
  const RateLimitedException({this.retryAfter, String? message})
    : super(message ?? 'Too many requests. Please slow down.');

  /// Server-provided cooldown, when it sent one. Honor it as-is.
  final Duration? retryAfter;
}

/// Any other 4xx: the request itself was wrong, so retrying will not help.
final class ClientException extends AppException {
  const ClientException(this.statusCode, [super.message = 'Request rejected.']);

  final int statusCode;
}

/// 5xx — transient by assumption, safe to retry with backoff.
final class ServerException extends AppException {
  const ServerException(this.statusCode, [super.message = 'Server error.']);

  final int statusCode;
}

/// The response arrived but did not match the contract.
final class DataFormatException extends AppException {
  const DataFormatException([super.message = 'Unexpected server response.']);
}

/// Secure storage refused to hold a credential — the device may have no
/// keystore, or the entry may be locked.
final class SecureStorageException extends AppException {
  const SecureStorageException([
    super.message = 'Could not securely save your session.',
  ]);
}

/// Input rejected before it ever left the device.
final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'Something went wrong.']);
}
