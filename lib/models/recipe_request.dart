class RecipeRequest {
  final List<String> ingredients;
  final bool isVegetarian;
  final String style; // 'home' or 'restaurant'
  final String depth; // 'quick' or 'detailed'
  final String language;

  RecipeRequest({
    required this.ingredients,
    required this.isVegetarian,
    required this.style,
    required this.depth,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredients': ingredients,
      'is_vegetarian': isVegetarian,
      'style': style,
      'depth': depth,
      'language': language,
    };
  }
}
