import 'env.dart';

class AppConfig {
  // OpenRouter API Configuration
  static const String openRouterApiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  // List of VERIFIED Free Models (Updated Feb 2026)
  static const List<String> freeModels = [
    'liquid/lfm-2.5-1.2b-instruct:free',       // Extremely fast & reliable
    'stepfun/step-3.5-flash:free',             // High performance free model
    'mistralai/mistral-7b-instruct:free',      // Standard fallback (check availability)
    'google/gemini-2.0-flash-lite-preview-02-05:free', // New Google model
    'openrouter/free',                         // Ultimate fallback (auto-router)
  ];
  
  // Getter for the primary model (first in list)
  static String get aiModel => freeModels.first;
  
  // API Key - Replace with your actual OpenRouter API key
  
  // API Key - Replace with your actual OpenRouter API key
  static const String apiKey = Env.openRouterApiKey;
  
  // App Metadata
  static const String appName = 'Tastemaker AI';
  static const String tagline = 'Your Personal AI Chef';
  static const String appLink = 'https://tastemaker-ai.app'; // Update with actual link
  
  // Request Configuration - Increased timeout for API calls
  static const Duration requestTimeout = Duration(seconds: 90);
  static const int maxRetries = 3;
  
  // Languages Supported
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिंदी'},
  ];
}
