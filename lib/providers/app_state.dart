import 'package:flutter/material.dart';
import '../models/recipe.dart';

class AppState extends ChangeNotifier {
  // Language
  String _selectedLanguage = 'en';
  String get selectedLanguage => _selectedLanguage;

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Mode (Veg/Non-Veg)
  bool _isVegetarian = true;
  bool get isVegetarian => _isVegetarian;

  void setMode(bool isVeg) {
    _isVegetarian = isVeg;
    _ingredients.clear(); // Clear ingredients when switching modes
    notifyListeners();
  }

  // Ingredients
  final List<String> _ingredients = [];
  List<String> get ingredients => List.unmodifiable(_ingredients);

  void addIngredient(String ingredient) {
    if (ingredient.trim().isNotEmpty && !_ingredients.contains(ingredient.trim())) {
      _ingredients.add(ingredient.trim());
      notifyListeners();
    }
  }

  void removeIngredient(String ingredient) {
    _ingredients.remove(ingredient);
    notifyListeners();
  }

  void clearIngredients() {
    _ingredients.clear();
    notifyListeners();
  }

  // Style
  String _selectedStyle = 'home';
  String get selectedStyle => _selectedStyle;

  void setStyle(String style) {
    _selectedStyle = style;
    notifyListeners();
  }

  // Depth
  String _selectedDepth = 'quick';
  String get selectedDepth => _selectedDepth;

  void setDepth(String depth) {
    _selectedDepth = depth;
    notifyListeners();
  }

  // Current Recipe
  Recipe? _currentRecipe;
  Recipe? get currentRecipe => _currentRecipe;

  void setCurrentRecipe(Recipe recipe) {
    _currentRecipe = recipe;
    notifyListeners();
  }

  void clearRecipe() {
    _currentRecipe = null;
    notifyListeners();
  }

  // Reset for new recipe
  void resetForNewRecipe() {
    _ingredients.clear();
    _selectedStyle = 'home';
    _selectedDepth = 'quick';
    _currentRecipe = null;
    notifyListeners();
  }

  // Complete reset
  void reset() {
    _selectedLanguage = 'en';
    _isVegetarian = true;
    _ingredients.clear();
    _selectedStyle = 'home';
    _selectedDepth = 'quick';
    _currentRecipe = null;
    notifyListeners();
  }
}
