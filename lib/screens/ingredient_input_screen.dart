import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/ingredient_validator.dart';

class IngredientInputScreen extends StatefulWidget {
  const IngredientInputScreen({super.key});

  @override
  State<IngredientInputScreen> createState() => _IngredientInputScreenState();
}

class _IngredientInputScreenState extends State<IngredientInputScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addIngredient(AppState appState) {
    final ingredient = _controller.text.trim();
    if (ingredient.isEmpty) return;

    // Add ingredient temporarily to check validation
    final tempIngredients = [...appState.ingredients, ingredient];

    // Validate
    final validationResult = IngredientValidator.validate(
      ingredients: tempIngredients,
      isVegetarian: appState.isVegetarian,
    );

    if (!validationResult.isValid) {
      setState(() {
        _errorMessage = validationResult.errorMessage;
      });
      return;
    }

    // If valid, add ingredient
    appState.addIngredient(ingredient);
    _controller.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  void _proceedToNext() {
    final appState = context.read<AppState>();

    // Validate before proceeding
    final validationResult = IngredientValidator.validate(
      ingredients: appState.ingredients,
      isVegetarian: appState.isVegetarian,
    );

    if (!validationResult.isValid) {
      setState(() {
        _errorMessage = validationResult.errorMessage;
      });
      return;
    }

    Navigator.pushNamed(context, '/style');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(appState.isVegetarian ? '🥦 Vegetarian' : '🍗 Non-Vegetarian'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  appState.clearIngredients();
                  setState(() {
                    _errorMessage = null;
                  });
                },
                tooltip: 'Clear all',
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Your Ingredients',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    appState.isVegetarian
                        ? 'Add up to 5 vegetables'
                        : 'Add 1 non-veg and vegetables',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.darkGrey.withValues(alpha: 0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // Input field
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter ingredient...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle, color: AppTheme.freshGreen),
                        onPressed: () => _addIngredient(appState),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addIngredient(appState),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Ingredient chips
                  Expanded(
                    child: appState.ingredients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_shopping_cart,
                                  size: 80,
                                   color: AppTheme.darkGrey.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No ingredients added yet',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                         color: AppTheme.darkGrey.withValues(alpha: 0.5),
                                      ),
                                ),
                              ],
                            ),
                          )
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: appState.ingredients.map((ingredient) {
                              final isNonVeg = IngredientValidator.isNonVegIngredient(ingredient);
                              return Chip(
                                label: Text(ingredient),
                                backgroundColor: isNonVeg
                                    ? AppTheme.warmOrange.withValues(alpha: 0.2)
                                    : AppTheme.mintGreen,
                                deleteIcon: const Icon(Icons.close),
                                onDeleted: () {
                                  appState.removeIngredient(ingredient);
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                },
                                avatar: Text(isNonVeg ? '🍗' : '🥦'),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 20),
                  // Cook Now button
                  ElevatedButton(
                    onPressed: appState.ingredients.isEmpty ? null : _proceedToNext,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Cook Now 👨‍🍳'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
