import '../models/recipe.dart';
import '../models/recipe_request.dart';
import '../utils/app_error.dart';
import '../utils/app_logger.dart';
import '../utils/input_sanitizer.dart';
import '../utils/prompt_builder.dart';
import 'openrouter_service.dart';

class RecipeGenerator {
  /// Generates a [Recipe] from a [RecipeRequest].
  ///
  /// All errors are typed [AppError] — callers should handle them
  /// and display [AppError.userMessage] in the UI.
  static Future<Recipe> generateRecipe(RecipeRequest request) async {
    // ── Sanitize inputs before building prompt ─────────────────────────────
    final safeIngredients =
        InputSanitizer.sanitizeIngredientList(request.ingredients);

    if (safeIngredients.isEmpty) {
      throw AppError(
        kind: AppErrorKind.validationError,
        userMessage: 'Please add at least one valid ingredient.',
        technicalDetail: 'All ingredients were rejected by sanitizer',
      );
    }

    AppLogger.info(
      'Generating recipe',
      'ingredients=${safeIngredients.length} '
          'veg=${request.isVegetarian} style=${request.style} '
          'depth=${request.depth} lang=${request.language}',
    );

    // ── Build prompt ───────────────────────────────────────────────────────
    final prompt = PromptBuilder.buildRecipePrompt(
      ingredients: safeIngredients,
      isVegetarian: request.isVegetarian,
      style: request.style,
      depth: request.depth,
      language: request.language,
    );

    // ── Call API ───────────────────────────────────────────────────────────
    // AppError propagates from OpenRouterService unchanged.
    final response = await OpenRouterService.generateRecipe(prompt: prompt);

    // ── Parse response ─────────────────────────────────────────────────────
    if (response.containsKey('raw_content')) {
      AppLogger.warning('AI returned raw non-JSON content');
      throw AppError.invalidAiResponse(
        'raw_content key present: ${response['raw_content']}',
      );
    }

    try {
      final recipe = Recipe.fromJson(response);
      AppLogger.info('Recipe parsed successfully', recipe.name);
      return recipe;
    } catch (e, st) {
      AppLogger.error('Recipe.fromJson failed', e, st);
      throw AppError.invalidAiResponse(e.toString());
    }
  }
}
