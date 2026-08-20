import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/env.dart';
import '../utils/app_error.dart';
import '../utils/app_logger.dart';
import '../utils/rate_limiter.dart';

class OpenRouterService {
  /// Generates a recipe by trying each model in [AppConfig.freeModels] in order.
  ///
  /// Throws [AppError] on all failure modes — callers must handle it.
  static Future<Map<String, dynamic>> generateRecipe({
    required String prompt,
  }) async {
    // ── Pre-flight checks ──────────────────────────────────────────────────

    // 1. Verify API key is configured
    if (!Env.hasApiKey) {
      throw AppError.missingApiKey();
    }

    // 2. Client-side rate limit
    final throttleMessage = RateLimiter.checkAllowed();
    if (throttleMessage != null) {
      throw AppError(
        kind: AppErrorKind.validationError,
        userMessage: throttleMessage,
        technicalDetail: 'Client-side rate limit enforced',
      );
    }

    // ── Model fallback chain ───────────────────────────────────────────────
    final List<String> errors = [];

    for (final model in AppConfig.freeModels) {
      AppLogger.info('Attempting recipe generation', 'model=$model');

      try {
        final response = await http
            .post(
              Uri.parse(AppConfig.openRouterApiUrl),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${AppConfig.apiKey}',
                'HTTP-Referer': AppConfig.appLink,
                'X-Title': AppConfig.appName,
              },
              body: jsonEncode({
                'model': model,
                'messages': [
                  {'role': 'user', 'content': prompt},
                ],
                // Ask for JSON output when the model supports it
                'response_format': {'type': 'json_object'},
              }),
            )
            .timeout(AppConfig.requestTimeout);

        // ── 429 Rate Limited ───────────────────────────────────────────────
        if (response.statusCode == 429) {
          AppLogger.warning('Rate limited by OpenRouter', 'model=$model');
          errors.add('Model $model: HTTP 429 — rate limited');
          continue;
        }

        // ── Other HTTP errors ──────────────────────────────────────────────
        if (response.statusCode != 200) {
          AppLogger.warning(
            'Non-200 response',
            'model=$model status=${response.statusCode}',
          );
          errors.add(
              'Model $model: HTTP ${response.statusCode} — ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
          continue;
        }

        // ── Parse success response ─────────────────────────────────────────
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;

        if (choices == null || choices.isEmpty) {
          errors.add('Model $model: empty choices array');
          AppLogger.warning('Empty choices', 'model=$model');
          continue;
        }

        final content =
            (choices[0] as Map<String, dynamic>)['message']?['content']
                as String?;
        if (content == null || content.isEmpty) {
          errors.add('Model $model: null/empty content');
          continue;
        }

        // ── Extract JSON from content ──────────────────────────────────────
        // Some models wrap their JSON in markdown fences; regex handles that.
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch == null) {
          AppLogger.warning('No JSON found in response', 'model=$model');
          return {'raw_content': content};
        }

        final parsed =
            jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

        // ── Record successful request for rate limiting ────────────────────
        RateLimiter.recordRequest();
        AppLogger.info('Recipe generated successfully', 'model=$model');

        return parsed;
      } on TimeoutException {
        AppLogger.warning('Request timed out', 'model=$model');
        errors.add('Model $model: timed out after ${AppConfig.requestTimeout.inSeconds}s');
      } on AppError {
        rethrow; // Let typed errors propagate immediately
      } catch (e, st) {
        AppLogger.error('Unexpected error during API call', e, st);
        errors.add('Model $model: ${e.runtimeType} — $e');
      }
    }

    // ── All models exhausted ───────────────────────────────────────────────
    final detail = errors.join('\n');
    AppLogger.error('All AI models failed', detail);
    throw AppError.allModelsFailed(detail);
  }
}
