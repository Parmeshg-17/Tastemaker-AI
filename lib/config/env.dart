/// SECURITY: API keys must NEVER be hardcoded in source.
/// 
/// HOW TO PASS THE KEY SAFELY:
///   flutter run --dart-define=OPENROUTER_API_KEY=sk-or-v1-xxxx
///   flutter build apk --dart-define=OPENROUTER_API_KEY=sk-or-v1-xxxx
///
/// For CI/CD (GitHub Actions example):
///   run: flutter build apk --dart-define=OPENROUTER_API_KEY=${{ secrets.OPENROUTER_API_KEY }}
///
/// The value is compiled into the binary via dart-define,
/// NOT stored in source control. Never commit a real key here.
class Env {
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '', // Empty default — app will surface a config error at runtime
  );

  /// Returns true if the key is present and non-empty.
  static bool get hasApiKey => openRouterApiKey.isNotEmpty;
}
