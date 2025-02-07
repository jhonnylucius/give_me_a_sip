class Cocktail {
  final String idDrink;
  final String strDrink;
  final String? strDrinkAlternate;
  final String? strTags;
  final String? strCategory;
  final String? strIBA;
  final String? strAlcoholic;
  final String? strGlass;
  final String strInstructions;
  final String? strDrinkThumb;
  final List<String?> ingredients;
  final List<String?> measures;

  Cocktail({
    required this.idDrink,
    required this.strDrink,
    this.strDrinkAlternate,
    this.strTags,
    this.strCategory,
    this.strIBA,
    this.strAlcoholic,
    this.strGlass,
    required this.strInstructions,
    this.strDrinkThumb,
    required this.ingredients,
    required this.measures,
  });

  factory Cocktail.fromJson(Map<String, dynamic> json) {
    List<String?> ingredients = [];
    List<String?> measures = [];

    for (int i = 1; i <= 15; i++) {
      String ingredientKey = 'strIngredient$i';
      String measureKey = 'strMeasure$i';

      ingredients.add(json[ingredientKey] as String?);
      measures.add(json[measureKey] as String?);
    }

    return Cocktail(
      idDrink: json['idDrink'] ?? '',
      strDrink: json['strDrink'] ?? '',
      strDrinkAlternate: json['strDrinkAlternate'] as String?,
      strTags: json['strTags'] as String?,
      strCategory: json['strCategory'] as String?,
      strIBA: json['strIBA'] as String?,
      strAlcoholic: json['strAlcoholic'] as String?,
      strGlass: json['strGlass'] as String?,
      strInstructions: json['strInstructions'] ?? '',
      strDrinkThumb: json['strDrinkThumb'] as String?,
      ingredients: ingredients,
      measures: measures,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['idDrink'] = idDrink;
    data['strDrink'] = strDrink;
    data['strDrinkAlternate'] = strDrinkAlternate;
    data['strTags'] = strTags;
    data['strCategory'] = strCategory;
    data['strIBA'] = strIBA;
    data['strAlcoholic'] = strAlcoholic;
    data['strGlass'] = strGlass;
    data['strInstructions'] = strInstructions;
    data['strDrinkThumb'] = strDrinkThumb;

    for (int i = 0; i < ingredients.length; i++) {
      data['strIngredient${i + 1}'] = ingredients[i];
      data['strMeasure${i + 1}'] = measures[i];
    }

    return data;
  }

  Cocktail copyWith({
    String? idDrink,
    String? strDrink,
    String? strDrinkAlternate,
    String? strTags,
    String? strCategory,
    String? strIBA,
    String? strAlcoholic,
    String? strGlass,
    String? strInstructions,
    String? strDrinkThumb,
    List<String?>? ingredients,
    List<String?>? measures,
  }) {
    return Cocktail(
      idDrink: idDrink ?? this.idDrink,
      strDrink: strDrink ?? this.strDrink,
      strDrinkAlternate: strDrinkAlternate ?? this.strDrinkAlternate,
      strTags: strTags ?? this.strTags,
      strCategory: strCategory ?? this.strCategory,
      strIBA: strIBA ?? this.strIBA,
      strAlcoholic: strAlcoholic ?? this.strAlcoholic,
      strGlass: strGlass ?? this.strGlass,
      strInstructions: strInstructions ?? this.strInstructions,
      strDrinkThumb: strDrinkThumb ?? this.strDrinkThumb,
      ingredients: ingredients ?? this.ingredients,
      measures: measures ?? this.measures,
    );
  }

  // Getters e Métodos Utilitários
  String get imageUrl => strDrinkThumb ?? '';
  String get thumbnailUrl => '$strDrinkThumb/preview';
  String get name => strDrink;
  String get category => strCategory ?? '';
  String get alcohol => strAlcoholic ?? '';
  String get glass => strGlass ?? '';
  String get instructions => strInstructions;
  String get tags => strTags ?? '';
  String get ingredientListString => ingredients.whereType<String>().join(', ');
  String get measureListString => measures.whereType<String>().join(', ');
  String get iba => strIBA ?? '';

  // Validações
  bool get hasAlternateName => strDrinkAlternate != null;
  bool get hasId => idDrink.isNotEmpty;
  bool get hasName => strDrink.isNotEmpty;
  bool get hasInstructions => strInstructions.isNotEmpty;
  bool get hasThumbnail => strDrinkThumb != null;
  bool get hasGlass => strGlass != null;
  bool get hasCategory => strCategory != null;
  bool get hasAlcohol => strAlcoholic != null;
  bool get hasIngredients =>
      ingredients.any((ingredient) => ingredient != null);
  bool get hasMeasures => measures.any((measure) => measure != null);
  bool get hasTags => strTags != null;
  bool get hasIBA => strIBA != null;

  // Métodos Utilitários Adicionais
  String getIngredientImageUrl(String ingredient,
      {ImageSize size = ImageSize.medium}) {
    final sanitizedIngredient = _sanitizeIngredientName(ingredient);
    final sizeStr = size == ImageSize.small
        ? '-Small'
        : size == ImageSize.medium
            ? '-Medium'
            : '';
    return 'https://www.thecocktaildb.com/images/ingredients/$sanitizedIngredient$sizeStr.png';
  }

  List<Map<String, String>> getIngredientsWithMeasures() {
    List<Map<String, String>> result = [];
    for (int i = 0; i < ingredients.length; i++) {
      if (ingredients[i] != null && ingredients[i]!.isNotEmpty) {
        result.add({
          'ingredient': ingredients[i]!,
          'measure': measures[i] ?? 'To taste',
        });
      }
    }
    return result;
  }

  String getFormattedInstructions() {
    if (strInstructions.isEmpty) return '';
    return strInstructions.split('. ').map((s) => '• $s').join('\n');
  }

  String _sanitizeIngredientName(String ingredient) {
    return ingredient.replaceAll(' ', '%20');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cocktail &&
          runtimeType == other.runtimeType &&
          idDrink == other.idDrink;

  @override
  int get hashCode => idDrink.hashCode;

  @override
  String toString() =>
      'Cocktail(id: $idDrink, name: $name, category: $category, imageUrl: $imageUrl)';
}

enum ImageSize {
  small, // 100x100
  medium, // 350x350
  large // 700x700
}
