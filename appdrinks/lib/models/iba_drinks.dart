class IBADrink {
  final String id;
  final String name;
  final String category;
  final String alcoholic;
  final String glass;
  final String? videoUrl;
  final Map<String, String> instructions;
  final List<IngredientInfo> ingredients;

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  String get idDrink => id;

  IBADrink({
    required this.id,
    required this.name,
    required this.category,
    required this.alcoholic,
    required this.glass,
    this.videoUrl,
    required this.instructions,
    required this.ingredients,
  });

  factory IBADrink.fromJson(Map<String, dynamic> json) {
    // Processa ingredientes do formato IBA
    List<IngredientInfo> processIngredients(List<dynamic>? ingredientsList) {
      if (ingredientsList == null) return [];

      return ingredientsList.map((ingredient) {
        return IngredientInfo(
          name: ingredient['name'] ?? '',
          measure: ingredient['measure'] ?? '',
          imageUrl: ingredient['imageUrl'] ?? '',
        );
      }).toList();
    }

    return IBADrink(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      alcoholic: json['alcoholic']?.toString() ?? '',
      glass: json['glass']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString(),
      instructions: Map<String, String>.from(json['instructions'] ?? {}),
      ingredients: processIngredients(json['ingredients'] as List?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'alcoholic': alcoholic,
      'glass': glass,
      'videoUrl': videoUrl,
      'instructions': instructions,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
    };
  }

  String getDrinkImageUrl() {
    return 'assets/data/images/drinks_iba/$id.webp';
  }

  // Métodos auxiliares similares ao Cocktail
  String getFormattedInstructions(String languageCode) {
    final instruction = instructions[languageCode] ?? instructions['en'] ?? '';
    if (instruction.isEmpty) return '';
    return instruction.split('. ').map((s) => '• $s').join('\n');
  }

  List<Map<String, String>> getIngredientsWithMeasures() {
    return ingredients
        .map((ingredient) => {
              'ingredient': ingredient.name,
              'measure': ingredient.measure,
              'imageUrl': ingredient.imageUrl,
            })
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IBADrink && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class IngredientInfo {
  final String name;
  final String measure;
  final String imageUrl;

  IngredientInfo({
    required this.name,
    required this.measure,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'measure': measure,
        'imageUrl': imageUrl,
      };

  factory IngredientInfo.fromJson(Map<String, dynamic> json) {
    return IngredientInfo(
      name: json['name'] ?? '',
      measure: json['measure'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
