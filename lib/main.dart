import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/depth_selection_screen.dart';
import 'screens/ingredient_input_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/recipe_output_screen.dart';
import 'screens/style_selection_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'utils/app_logger.dart';
import 'services/monitoring_service.dart';
import 'widgets/error_boundary.dart';

Future<void> main() async {
  // Must be called before any Flutter framework usage.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize monitoring (crash reporting, analytics, performance).
  await MonitoringService.initialize();

  // ── Orientation lock ──────────────────────────────────────────────────────
  // Portrait-only — the wizard UX is designed for portrait.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status bar styling ────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // ── Crash reporting wiring ────────────────────────────────────────────────
  // Wire AppLogger into your crash reporter here before runApp.
  // Example for Firebase Crashlytics (uncomment when SDK is added):
  //
  //   await Firebase.initializeApp();
  //   AppLogger.onError = (message, error, stackTrace) {
  //     FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
  //   };
  //   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // ── Zone-based async error capture ────────────────────────────────────────
  // Catches errors thrown inside async callbacks that are not caught
  // by any try/catch (e.g., dart:async Futures that fire after dispose).
  runZonedGuarded(
    () => runApp(const ErrorBoundary(child: TastemakerAI())),
    (error, stackTrace) {
      AppLogger.error(
        'Uncaught async error (runZonedGuarded)',
        error,
        stackTrace,
      );
    },
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// Root Widget
// ═════════════════════════════════════════════════════════════════════════════

class TastemakerAI extends StatelessWidget {
  const TastemakerAI({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Tastemaker AI',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/welcome',
        // ── Named routes ────────────────────────────────────────────────────
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/language': (context) => const LanguageSelectionScreen(),
          '/mode': (context) => const ModeSelectionScreen(),
          '/ingredients': (context) => const ExitHandlerWrapper(
                child: IngredientInputScreen(),
              ),
          '/style': (context) => const StyleSelectionScreen(),
          '/depth': (context) => const DepthSelectionScreen(),
          '/loading': (context) => const LoadingScreen(),
          '/recipe': (context) => const ExitHandlerWrapper(
                child: RecipeOutputScreen(),
              ),
        },
        // ── Global route error page ──────────────────────────────────────────
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const _NotFoundPage(),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 404 Fallback Page
// ═════════════════════════════════════════════════════════════════════════════

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tastemaker AI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 64, color: AppTheme.freshGreen),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/welcome'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Exit Handler Wrapper
// ═════════════════════════════════════════════════════════════════════════════

/// Wraps screens that need double-back-press exit confirmation.
class ExitHandlerWrapper extends StatefulWidget {
  final Widget child;

  const ExitHandlerWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ExitHandlerWrapper> createState() => _ExitHandlerWrapperState();
}

class _ExitHandlerWrapperState extends State<ExitHandlerWrapper> {
  DateTime? _lastBackPress;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
            backgroundColor: AppTheme.freshGreen,
          ),
        );
      }
      return false;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Exit Tastemaker AI?'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: widget.child,
    );
  }
}
