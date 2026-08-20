// Performance monitoring and crash reporting service.
//
// This file is the single integration point for your observability stack.
// All platform SDKs are wired here so switching providers means touching
// only this one file — no changes to business logic.
//
// Current state: logging-only (no SDK dependency).
// To activate a real provider, follow the steps in each section below.

import 'dart:async';
import '../utils/app_logger.dart';

// ─── Uncomment when adding Firebase ──────────────────────────────────────
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_performance/firebase_performance.dart';

// ─── Uncomment when adding Sentry ────────────────────────────────────────
// import 'package:sentry_flutter/sentry_flutter.dart';

class MonitoringService {
  MonitoringService._();

  static bool _initialized = false;

  // ── Initialization ──────────────────────────────────────────────────────

  /// Call once in main(), before runApp().
  ///
  /// Steps to activate Firebase:
  ///   1. `flutterfire configure` (generates google-services.json / GoogleService-Info.plist)
  ///   2. Add firebase_core, firebase_crashlytics, firebase_analytics, firebase_performance
  ///      to pubspec.yaml (uncomment the lines there)
  ///   3. Uncomment the Firebase blocks below
  static Future<void> initialize() async {
    if (_initialized) return;

    // ── Firebase init (uncomment) ─────────────────────────────────────────
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    // ── Crashlytics wiring (uncomment) ────────────────────────────────────
    // Wire up AppLogger so all AppError.error() calls flow into Crashlytics:
    //
    // AppLogger.onError = (message, error, stackTrace) async {
    //   await FirebaseCrashlytics.instance.recordError(
    //     error,
    //     stackTrace,
    //     reason: message,
    //     fatal: false,
    //   );
    // };
    //
    // // Also catch Flutter framework errors:
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // ── Sentry alternative (uncomment instead of Firebase) ────────────────
    // await SentryFlutter.init(
    //   (options) {
    //     options.dsn = const String.fromEnvironment('SENTRY_DSN');
    //     options.tracesSampleRate = 0.2;   // 20% of sessions
    //     options.profilesSampleRate = 0.1; // 10% profiling
    //     options.environment = const String.fromEnvironment(
    //       'APP_ENV', defaultValue: 'production');
    //   },
    // );

    _initialized = true;
    AppLogger.info('MonitoringService initialized');
  }

  // ── User identity ────────────────────────────────────────────────────────

  /// Associate a user ID with crash reports and analytics sessions.
  /// Call after successful authentication (when you add it).
  static void setUserId(String userId) {
    // FirebaseCrashlytics.instance.setUserIdentifier(userId);
    // FirebaseAnalytics.instance.setUserId(id: userId);
    AppLogger.debug('MonitoringService.setUserId', userId);
  }

  // ── Screen tracking ──────────────────────────────────────────────────────

  /// Log a screen view event.
  ///
  /// Usage — call at the start of each screen's initState():
  ///   MonitoringService.logScreen('welcome');
  ///   MonitoringService.logScreen('recipe_output');
  static void logScreen(String screenName) {
    // FirebaseAnalytics.instance.logScreenView(screenName: screenName);
    AppLogger.debug('Screen view', screenName);
  }

  // ── Custom events ────────────────────────────────────────────────────────

  /// Log a named custom event with optional parameters.
  ///
  /// Recommended events for Tastemaker AI:
  ///   MonitoringService.logEvent('recipe_generated', {'model': model, 'depth': depth});
  ///   MonitoringService.logEvent('recipe_shared');
  ///   MonitoringService.logEvent('language_selected', {'language': lang});
  static void logEvent(String name, [Map<String, dynamic>? parameters]) {
    // FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
    AppLogger.debug('Analytics event: $name', parameters);
  }

  // ── Performance traces ───────────────────────────────────────────────────

  /// Start a named performance trace. Returns it so you can stop it.
  ///
  /// Usage:
  ///   final trace = await MonitoringService.startTrace('recipe_api_call');
  ///   // ... do work ...
  ///   await trace.stop();
  static Future<MonitoringTrace> startTrace(String name) async {
    AppLogger.debug('Trace start', name);
    // Uncomment for Firebase Performance:
    // final trace = FirebasePerformance.instance.newTrace(name);
    // await trace.start();
    // return _FirebaseTrace(trace);
    return _LogTrace(name, DateTime.now());
  }

  // ── Error recording ──────────────────────────────────────────────────────

  /// Manually record a non-fatal error (e.g. a recoverable AppError).
  static Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    AppLogger.error(reason ?? 'Recorded error', error, stackTrace);

    // FirebaseCrashlytics.instance.recordError(
    //   error, stackTrace, reason: reason, fatal: fatal);

    // Sentry alternative:
    // await Sentry.captureException(error, stackTrace: stackTrace,
    //   hint: Hint.withMap({'reason': reason ?? ''}));
  }
}

// ── Internal trace abstractions ──────────────────────────────────────────────

abstract class MonitoringTrace {
  Future<void> stop();
  void putAttribute(String name, String value);
}

/// No-op trace that logs start/stop durations — used until a real SDK is wired.
class _LogTrace implements MonitoringTrace {
  final String name;
  final DateTime _start;

  _LogTrace(this.name, this._start);

  @override
  Future<void> stop() async {
    final ms = DateTime.now().difference(_start).inMilliseconds;
    AppLogger.debug('Trace stop', '$name completed in ${ms}ms');
  }

  @override
  void putAttribute(String name, String value) {
    AppLogger.debug('Trace attribute', '$name=$value');
  }
}
