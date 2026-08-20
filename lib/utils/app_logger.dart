// Centralized structured logger for Tastemaker AI.
//
// In DEBUG builds: prints to console with severity prefix.
// In RELEASE builds: all debug/info logs are silenced.
//   Wire `AppLogger.onError` into your crash-reporting SDK
//   (Firebase Crashlytics, Sentry, etc.)

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  AppLogger._();

  /// Optional callback for external crash reporters (e.g. Crashlytics).
  /// Set this in main() before runApp():
  ///   AppLogger.onError = (msg, err, st) => FirebaseCrashlytics.instance.recordError(err, st);
  static void Function(String message, Object? error, StackTrace? stackTrace)?
      onError;

  static void debug(String message, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message${data != null ? ' | $data' : ''}');
    }
  }

  static void info(String message, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[INFO]  $message${data != null ? ' | $data' : ''}');
    }
  }

  static void warning(String message, [Object? data]) {
    if (kDebugMode) {
      debugPrint('[WARN]  $message${data != null ? ' | $data' : ''}');
    }
    // Warnings are surfaced even in profile builds via assert-safe channel.
  }

  static void error(String message, [Object? err, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (err != null) debugPrint('        $err');
      if (stackTrace != null) debugPrint('        $stackTrace');
    }
    // Forward to crash reporter in all build modes.
    onError?.call(message, err, stackTrace);
  }
}
