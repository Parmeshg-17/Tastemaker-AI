class IngredientValidator {
  static const int maxVegIngredients = 5;
  static const int maxNonVegIngredients = 1;

  // Common non-veg ingredients
  static const List<String> nonVegKeywords = [
    'chicken',
    'mutton',
    'lamb',
    'beef',
    'pork',
    'fish',
    'prawn',
    'shrimp',
    'crab',
    'egg',
    'meat',
    'turkey',
  ];

  static ValidationResult validate({
    required List<String> ingredients,
    required bool isVegetarian,
  }) {
    if (ingredients.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please add at least one ingredient',
      );
    }

    if (isVegetarian) {
      // Check for non-veg ingredients in veg mode
      for (final ingredient in ingredients) {
        if (_containsNonVeg(ingredient)) {
          return ValidationResult(
            isValid: false,
            errorMessage: 'Non-vegetarian ingredient "$ingredient" not allowed in Vegetarian mode',
          );
        }
      }

      // Check max limit
      if (ingredients.length > maxVegIngredients) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Maximum $maxVegIngredients vegetables allowed in Vegetarian mode',
        );
      }
    } else {
      // Non-veg mode
      final nonVegCount = ingredients.where((i) => _containsNonVeg(i)).length;

      if (nonVegCount > maxNonVegIngredients) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Only $maxNonVegIngredients non-veg ingredient allowed in Non-Vegetarian mode',
        );
      }

      if (nonVegCount == 0) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Please add at least one non-vegetarian ingredient',
        );
      }
    }

    return ValidationResult(isValid: true);
  }

  static bool _containsNonVeg(String ingredient) {
    final lowerIngredient = ingredient.toLowerCase();
    return nonVegKeywords.any((keyword) => lowerIngredient.contains(keyword));
  }

  static bool isNonVegIngredient(String ingredient) {
    return _containsNonVeg(ingredient);
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
