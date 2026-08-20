import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Choose your preferred language',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'अपनी भाषा चुनें',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.darkGrey.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: AppConfig.supportedLanguages.length,
                itemBuilder: (context, index) {
                  final language = AppConfig.supportedLanguages[index];
                  return _LanguageCard(
                    languageCode: language['code']!,
                    languageName: language['name']!,
                    nativeName: language['nativeName']!,
                    onTap: () {
                      context.read<AppState>().setLanguage(language['code']!);
                      Navigator.pushReplacementNamed(context, '/mode');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final String nativeName;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.languageCode,
    required this.languageName,
    required this.nativeName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.language,
                  color: AppTheme.freshGreen,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nativeName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkGrey.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.freshGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
