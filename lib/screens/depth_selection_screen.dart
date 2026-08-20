import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class DepthSelectionScreen extends StatelessWidget {
  const DepthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Depth'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'How detailed should the recipe be?',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DepthCard(
                    emoji: '⚡',
                    title: 'Quick',
                    subtitle: 'Basic steps, fast cooking',
                    depth: 'quick',
                    onTap: () {
                      context.read<AppState>().setDepth('quick');
                      Navigator.pushNamed(context, '/loading');
                    },
                  ),
                  const SizedBox(height: 24),
                  _DepthCard(
                    emoji: '👨‍🍳',
                    title: 'Detailed Chef Style',
                    subtitle: 'Professional, step-by-step',
                    depth: 'detailed',
                    onTap: () {
                      context.read<AppState>().setDepth('detailed');
                      Navigator.pushNamed(context, '/loading');
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

class _DepthCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String depth;
  final VoidCallback onTap;

  const _DepthCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.depth,
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
                 AppTheme.warmOrange.withValues(alpha: 0.1),
                 AppTheme.warmOrange.withValues(alpha: 0.05),
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
                      color: AppTheme.warmOrange,
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
