class Recipe {
  final String name;
  final String style; // Home Style or Restaurant Style
  final String category; // Vegetarian or Non-Vegetarian
  final String cuisine;
  final List<String> ingredients;
  final List<String> steps;
  final String cookingTime;
  final String spiceLevel;
  final String servingSize;
  final NutritionInfo nutrition;
  final String chefTip;

  Recipe({
    required this.name,
    required this.style,
    required this.category,
    required this.cuisine,
    required this.ingredients,
    required this.steps,
    required this.cookingTime,
    required this.spiceLevel,
    required this.servingSize,
    required this.nutrition,
    required this.chefTip,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] ?? 'Delicious Recipe',
      style: json['style'] ?? '',
      category: json['category'] ?? '',
      cuisine: json['cuisine'] ?? 'Traditional Indian (Fresh & Green)',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      cookingTime: json['cooking_time'] ?? '',
      spiceLevel: json['spice_level'] ?? '',
      servingSize: json['serving_size'] ?? '',
      nutrition: NutritionInfo.fromJson(json['nutrition'] ?? {}),
      chefTip: json['chef_tip'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'style': style,
      'category': category,
      'cuisine': cuisine,
      'ingredients': ingredients,
      'steps': steps,
      'cooking_time': cookingTime,
      'spice_level': spiceLevel,
      'serving_size': servingSize,
      'nutrition': nutrition.toJson(),
      'chef_tip': chefTip,
    };
  }
}

class NutritionInfo {
  final String calories;
  final String protein;
  final String carbs;
  final String fat;
  final String fiber;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories']?.toString() ?? '0',
      protein: json['protein']?.toString() ?? '0',
      carbs: json['carbs']?.toString() ?? '0',
      fat: json['fat']?.toString() ?? '0',
      fiber: json['fiber']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }
}
