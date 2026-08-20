class PromptBuilder {
  static String buildRecipePrompt({
    required List<String> ingredients,
    required bool isVegetarian,
    required String style,
    required String depth,
    required String language,
  }) {
    final mode = isVegetarian ? 'Vegetarian' : 'Non-Vegetarian';
    final styleText = style == 'home' ? 'Home Style' : 'Restaurant Style';
    final depthText = depth == 'quick' ? 'Quick' : 'Detailed Chef Style';
    
    final ingredientsList = ingredients.join(', ');

    return '''
You are a professional Indian chef specializing in traditional Indian cuisine. Generate a ${styleText.toLowerCase()} ${mode.toLowerCase()} recipe with the following requirements:

Ingredients provided: $ingredientsList
Mode: $mode
Style: $styleText (${style == 'home' ? 'Simple, everyday home cooking' : 'Professional, restaurant-quality'})
Recipe Depth: $depthText (${depth == 'quick' ? 'Basic steps, fast cooking' : 'Detailed step-by-step instructions'})
Language: $language

IMPORTANT: Respond ONLY with valid JSON in this exact format:
{
  "name": "Recipe name with emoji",
  "style": "$styleText",
  "category": "$mode",
  "cuisine": "Traditional Indian (Fresh & Green)",
  "ingredients": [
    "ingredient 1 with quantity",
    "ingredient 2 with quantity"
  ],
  "steps": [
    "Step 1 description",
    "Step 2 description"
  ],
  "cooking_time": "X minutes",
  "spice_level": "Mild/Medium/Hot",
  "serving_size": "X servings",
  "nutrition": {
    "calories": "X kcal",
    "protein": "Xg",
    "carbs": "Xg",
    "fat": "Xg",
    "fiber": "Xg"
  },
  "chef_tip": "One helpful cooking tip"
}

The recipe should:
- Use the provided ingredients as the main ingredients
- Add appropriate Indian spices and aromatics
- Include ${depth == 'quick' ? '5-8' : '10-15'} clear cooking steps
- Provide realistic cooking time
- Include approximate nutrition values per serving
- Be authentic to traditional Indian cooking
- Match the selected style ($styleText)

Respond with ONLY the JSON, no additional text.
''';
  }
}
