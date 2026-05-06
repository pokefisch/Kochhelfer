// 1. Create a dedicated class just for Ingredients!
class Ingredient {
  final String name;
  final double amount;
  final String unit;

  Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      // We use .toDouble() because Python might send '1' instead of '1.0'
      amount: (json['amount'] ?? 0).toDouble(), 
      unit: json['unit'] ?? '',
    );
  }
}

// 2. Update your Recipe Model
class RecipeModel {
  final String title;
  final int prepTimeMinutes; // Now an integer!
  final String imageUrl;
  final int servings;
  final List<Ingredient> ingredients; // Now a list of Ingredient objects!

  RecipeModel({
    required this.title,
    required this.prepTimeMinutes,
    required this.imageUrl,
    required this.servings,
    required this.ingredients,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    
    // Safely convert the incoming JSON list into your new Ingredient objects
    var ingredientList = json['ingredients'] as List? ?? [];
    List<Ingredient> mappedIngredients = ingredientList.map((i) => Ingredient.fromJson(i)).toList();

    return RecipeModel(
      title: json['title'] ?? 'Unbekanntes Rezept',
      prepTimeMinutes: json['prep_time_minutes'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      servings: json['servings'] ?? 1,
      ingredients: mappedIngredients,
    );
  }
}