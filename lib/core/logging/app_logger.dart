import 'dart:developer' as developer;

import '../security/redactor.dart';

enum LogLevel { debug, info, warning, error }

/// The app's only logging entry point.
///
/// Uses `dart:developer` rather than `print` (which ships to release consoles),
/// drops noise below the configured level, and redacts every message so a
/// token or an email can never reach a log sink.
class AppLogger {
  const AppLogger({
    this.minimumLevel = LogLevel.debug,
    this.redactor = const Redactor(),
  });

  factory AppLogger.forEnvironment({required bool isProduction}) =>
      AppLogger(minimumLevel: isProduction ? LogLevel.warning : LogLevel.debug);

  final LogLevel minimumLevel;
  final Redactor redactor;

  void debug(String message) => _log(LogLevel.debug, message);

  void info(String message) => _log(LogLevel.info, message);

  void warning(String message) => _log(LogLevel.warning, message);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minimumLevel.index) return;
    developer.log(
      redactor.redact(message),
      name: 'happilab.${level.name}',
      level: (level.index + 1) * 200,
      error: error == null ? null : redactor.redact(error.toString()),
      stackTrace: stackTrace,
    );
  }
}
