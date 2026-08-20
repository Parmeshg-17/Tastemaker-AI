import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_request.dart';
import '../providers/app_state.dart';
import '../services/recipe_generator.dart';
import '../theme/app_theme.dart';
import '../utils/app_error.dart';
import '../utils/app_logger.dart';
import '../services/monitoring_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ── State ────────────────────────────────────────────────────────────────
  _ScreenState _screenState = _ScreenState.loading;
  String _userMessage = '';  // Safe to show in UI
  int _retryCount = 0;
  static const int _maxRetries = 2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    MonitoringService.logScreen('loading');
    _generateRecipe();
  }

  Future<void> _generateRecipe() async {
    setState(() => _screenState = _ScreenState.loading);

    try {
      final appState = context.read<AppState>();

      final request = RecipeRequest(
        ingredients: appState.ingredients,
        isVegetarian: appState.isVegetarian,
        style: appState.selectedStyle,
        depth: appState.selectedDepth,
        language: appState.selectedLanguage,
      );

      // Performance trace — measures end-to-end recipe generation latency
      final trace = await MonitoringService.startTrace('recipe_api_call');
      trace.putAttribute('depth', request.depth);
      trace.putAttribute('language', request.language);

      final recipe = await RecipeGenerator.generateRecipe(request);
      await trace.stop();

      MonitoringService.logEvent('recipe_generated', {
        'style': request.style,
        'depth': request.depth,
        'language': request.language,
        'is_vegetarian': request.isVegetarian.toString(),
        'ingredient_count': request.ingredients.length.toString(),
      });

      if (mounted) {
        appState.setCurrentRecipe(recipe);
        Navigator.pushReplacementNamed(context, '/recipe');
      }
    } on AppError catch (appErr) {
      AppLogger.error(
        'AppError in LoadingScreen',
        appErr,
        appErr.stackTrace,
      );
      if (mounted) {
        setState(() {
          _screenState = _ScreenState.error;
          _userMessage = appErr.userMessage;
          // technicalDetail is intentionally logged only, never shown in UI
        });
      }
    } catch (e, st) {
      // Unexpected non-AppError — wrap and log
      AppLogger.error('Unexpected error in LoadingScreen', e, st);
      if (mounted) {
        setState(() {
          _screenState = _ScreenState.error;
          _userMessage = 'An unexpected error occurred. Please try again.';
          // e.toString() intentionally kept in logs only
        });
      }
    }
  }

  void _retry() {
    _retryCount++;
    _generateRecipe();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return switch (_screenState) {
      _ScreenState.loading => _buildLoading(context),
      _ScreenState.error => _buildError(context),
    };
  }

  Widget _buildLoading(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppTheme.freshGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Hero(
                  tag: 'chef_hat',
                  child: Icon(
                    Icons.restaurant,
                    size: 80,
                    color: AppTheme.freshGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Tastemaker AI is cooking\nyour recipe...',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.freshGreen,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                color: AppTheme.freshGreen,
                backgroundColor: AppTheme.lightGreen,
              ),
            ),
            const SizedBox(height: 40),
            const Text('🍳 🔥 🌿 🥘', style: TextStyle(fontSize: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final canRetry = _retryCount < _maxRetries;

    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      appBar: AppBar(title: const Text('Oops!')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 56,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 28),

              // User-safe message
              Text(
                _userMessage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.darkGrey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Retry (limited attempts)
              if (canRetry) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Try Again (${_maxRetries - _retryCount} left)',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Go back
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ScreenState { loading, error }
