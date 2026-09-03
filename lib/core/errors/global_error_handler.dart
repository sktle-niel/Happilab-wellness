import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';

/// Last line of defence for anything no handler caught.
///
/// Every escaped error is logged through [AppLogger] — redacted, so a message
/// carrying a token or an address never reaches a log sink — and the app keeps
/// running instead of crashing on a fault the member can do nothing about.
/// In debug the red screen and console output stay: hiding a crash from the
/// developer is not resilience.
abstract final class GlobalErrorHandler {
  static void install(AppLogger logger) {
    final presentToDeveloper = FlutterError.onError;
    FlutterError.onError = (details) {
      logger.error(
        'Uncaught framework error',
        error: details.exception,
        stackTrace: details.stack,
      );
      if (kDebugMode) presentToDeveloper?.call(details);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      logger.error(
        'Uncaught platform error',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    };
  }
}
