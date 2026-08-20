import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class StyleSelectionScreen extends StatelessWidget {
  const StyleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Style'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'What style do you prefer?',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StyleCard(
                    emoji: '🏠',
                    title: 'Home Style',
                    subtitle: 'Simple, everyday cooking',
                    style: 'home',
                    onTap: () {
                      context.read<AppState>().setStyle('home');
                      Navigator.pushNamed(context, '/depth');
                    },
                  ),
                  const SizedBox(height: 24),
                  _StyleCard(
                    emoji: '🍽️',
                    title: 'Restaurant Style',
                    subtitle: 'Professional, premium recipes',
                    style: 'restaurant',
                    onTap: () {
                      context.read<AppState>().setStyle('restaurant');
                      Navigator.pushNamed(context, '/depth');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String style;
  final VoidCallback onTap;

  const _StyleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppTheme.freshGreen.withValues(alpha: 0.1),
                AppTheme.freshGreen.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.freshGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.darkGrey.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
