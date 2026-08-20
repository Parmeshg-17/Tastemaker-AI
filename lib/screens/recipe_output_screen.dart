import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/recipe_formatter.dart';
import '../utils/share_helper.dart';

class RecipeOutputScreen extends StatefulWidget {
  const RecipeOutputScreen({super.key});

  @override
  State<RecipeOutputScreen> createState() => _RecipeOutputScreenState();
}

class _RecipeOutputScreenState extends State<RecipeOutputScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final recipe = appState.currentRecipe;

        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Recipe'),
            ),
            body: const Center(
              child: Text('No recipe available'),
            ),
          );
        }

        final formattedRecipe = RecipeFormatter.formatForDisplay(recipe);

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Hero(
                  tag: 'chef_hat',
                  child: Icon(
                    Icons.restaurant,
                    color: AppTheme.freshGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Your Recipe'),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _showExitConfirmation(context, appState);
              },
            ),
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Recipe content card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SelectableText(
                          formattedRecipe,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                text: RecipeFormatter.formatForShare(
                                  recipe,
                                  AppConfig.appLink,
                                ),
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Recipe copied to clipboard!'),
                                  backgroundColor: AppTheme.freshGreen,
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await ShareHelper.shareRecipe(recipe);
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Generate new recipe button
                    OutlinedButton.icon(
                      onPressed: () {
                        appState.resetForNewRecipe();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/mode',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.refresh, color: AppTheme.freshGreen),
                      label: const Text('Generate New Recipe'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExitConfirmation(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Exit Tastemaker AI?'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.reset();
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/welcome',
                  (route) => false,
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
