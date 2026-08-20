// Global error boundary widget.
//
// Wraps the entire widget tree. Catches Flutter framework errors
// (layout, build, render) and shows a safe fallback UI instead of
// a crash red-screen. All caught errors are forwarded to AppLogger.

import 'package:flutter/material.dart';
import '../utils/app_logger.dart';
import '../theme/app_theme.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();

    // Override Flutter's default error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error(
        'Flutter framework error',
        details.exception,
        details.stack,
      );

      // In debug: also invoke the default (prints to console)
      FlutterError.dumpErrorToConsole(details);

      // Trigger rebuild with error state
      if (mounted) {
        setState(() => _error = details.exception);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _ErrorFallbackScreen(
          onRetry: () => setState(() => _error = null),
        ),
      );
    }
    return widget.child;
  }
}

class _ErrorFallbackScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorFallbackScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.freshGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    size: 64,
                    color: AppTheme.freshGreen,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Body
                const Text(
                  "The app encountered an unexpected issue. "
                  "Our team has been notified. Please try again.",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Retry
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
