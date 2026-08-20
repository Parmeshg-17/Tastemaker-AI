import 'package:share_plus/share_plus.dart';
import '../models/recipe.dart';
import '../utils/recipe_formatter.dart';
import '../config/app_config.dart';

class ShareHelper {
  static Future<void> shareRecipe(Recipe recipe) async {
    final shareText = RecipeFormatter.formatForShare(recipe, AppConfig.appLink);
    
    await Share.share(
      shareText,
      subject: 'Check out this recipe from Tastemaker AI!',
    );
  }

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
