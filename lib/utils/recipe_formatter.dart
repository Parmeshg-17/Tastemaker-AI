import '../models/recipe.dart';

class RecipeFormatter {
  static String formatForDisplay(Recipe recipe) {
    final buffer = StringBuffer();

    // Recipe name with emoji
    buffer.writeln('🍽️ ${recipe.name}\n');

    // Metadata
    buffer.writeln('👨‍🍳 Style: ${recipe.style}');
    buffer.writeln('🥦 Category: ${recipe.category}');
    buffer.writeln('🌿 Cuisine: ${recipe.cuisine}\n');

    // Ingredients
    buffer.writeln('🧺 Ingredients:');
    for (final ingredient in recipe.ingredients) {
      buffer.writeln('• $ingredient');
    }
    buffer.writeln();

    // Cooking steps
    buffer.writeln('👩‍🍳 Cooking Steps:');
    for (int i = 0; i < recipe.steps.length; i++) {
      buffer.writeln('${i + 1}. ${recipe.steps[i]}');
    }
    buffer.writeln();

    // Cooking info
    buffer.writeln('⏱️ Estimated Cooking Time: ${recipe.cookingTime}');
    buffer.writeln('🔥 Spice Level: ${recipe.spiceLevel}');
    buffer.writeln('🍽️ Serving Size: ${recipe.servingSize}\n');

    // Nutrition
    buffer.writeln('🥗 Nutrition (Approx per serving):');
    buffer.writeln('• Calories: ${recipe.nutrition.calories}');
    buffer.writeln('• Protein: ${recipe.nutrition.protein}');
    buffer.writeln('• Carbs: ${recipe.nutrition.carbs}');
    buffer.writeln('• Fat: ${recipe.nutrition.fat}');
    buffer.writeln('• Fiber: ${recipe.nutrition.fiber}\n');

    // Chef tip
    buffer.writeln('💡 Chef Tip:');
    buffer.writeln(recipe.chefTip);

    return buffer.toString();
  }

  static String formatForShare(Recipe recipe, String appLink) {
    final recipeText = formatForDisplay(recipe);

    return '''
🍽️ Recipe by Tastemaker AI

$recipeText

📱 Generated using Tastemaker AI
👉 Download Now: $appLink
''';
  }
}
