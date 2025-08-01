import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

@HiveType(typeId: 0)
class Cocktail {
  @HiveField(0)
  final String idDrink;

  @HiveField(1)
  final String strDrink;

  @HiveField(2)
  final String? strDrinkAlternate;

  @HiveField(3)
  final String? strTags;

  @HiveField(4)
  final String? strCategory;

  @HiveField(5)
  final String? strIBA;

  @HiveField(6)
  final String? strAlcoholic;

  @HiveField(7)
  final String? strGlass;

  @HiveField(8)
  final String strInstructions;

  @HiveField(9)
  final String? strDrinkThumb;

  @HiveField(10)
  final List<Map<String, dynamic>> ingredients;

  @HiveField(11)
  final List<String?> measures;

  @HiveField(12)
  final List<String?> originalIngredients;

  @HiveField(13)
  final Map<String, String>? translations;

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
    required this.originalIngredients,
    this.translations,
  });

  // CORREÇÃO: Modificar os getters para usar URLs da API quando disponíveis
  String get imageUrl => strDrinkThumb?.isNotEmpty == true
      ? strDrinkThumb!
      : 'assets/images/default_cocktail.webp';

  String get thumbnailUrl => strDrinkThumb?.isNotEmpty == true
      ? '$strDrinkThumb/preview'
      : 'assets/images/default_cocktail.webp';

  factory Cocktail.fromJson(Map<String, dynamic> json,
      {String language = 'en'}) {
    final ingredients = <String?>[];
    final measures = <String?>[];
    final originalIngredients = <String?>[];

    // CORREÇÃO: Garantir que os campos da API sejam corretamente mapeados
    for (var i = 1; i <= 15; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().isNotEmpty) {
        ingredients.add(ingredient);
        originalIngredients.add(ingredient);
        measures.add(measure);
      }
    }

    // Ajuste no tratamento das instruções
    final instructions = json['instructions'] is Map
        ? (json['instructions'][language] ?? json['instructions']['en'] ?? '')
        : json['instructions'] ?? '';

    return Cocktail(
      idDrink: json['id'] ?? json['idDrink'] ?? '',
      strDrink: json['name'] ?? json['strDrink'] ?? '',
      strDrinkAlternate: json['strDrinkAlternate'],
      strTags: json['strTags'],
      strCategory: json['category'] ?? json['strCategory'],
      strIBA: json['strIBA'],
      strAlcoholic: json['alcoholic'] ?? json['strAlcoholic'],
      strGlass: json['glass'] ?? json['strGlass'],
      strInstructions: instructions,
      strDrinkThumb:
          json['strDrinkThumb'], // CORREÇÃO: Não modificar a URL da imagem
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
      measures: measures,
      originalIngredients: originalIngredients,
      translations: json['translations'] != null
          ? Map<String, String>.from(json['translations'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = idDrink;
    data['name'] = strDrink;
    data['strDrinkAlternate'] = strDrinkAlternate;
    data['strTags'] = strTags;
    data['category'] = strCategory;
    data['strIBA'] = strIBA;
    data['alcohol'] = strAlcoholic;
    data['glass'] = strGlass;
    data['instructions'] = strInstructions;
    data['image'] = strDrinkThumb;
    data['translations'] = translations;

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
    List<Map<String, dynamic>>? ingredients,
    List<String?>? measures,
    List<String?>? originalIngredients,
    Map<String, String>? translations,
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
      originalIngredients: originalIngredients ?? this.originalIngredients,
      translations: translations ?? this.translations,
    );
  }

  // Getters (mantidos -  os getters `imageUrl` e `thumbnailUrl` foram movidos para perto da declaração das variáveis)
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
  bool get hasTranslations => translations != null && translations!.isNotEmpty;

  String getIngredientImageUrl(String ingredientName) {
    // Sanitizando o nome do ingrediente para o formato do arquivo
    final sanitized = ingredientName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return 'assets/data/images/ingredients/$sanitized.webp';
  }

  String getDrinkImageUrl() {
    return 'assets/data/images/drinks/$idDrink.webp';
  }

  List<Map<String, String>> getIngredientsWithMeasures() {
    List<Map<String, String>> result = [];
    for (int i = 0; i < ingredients.length; i++) {
      final ingredientName = ingredients[i]['name'];
      if (ingredientName != null && ingredientName.isNotEmpty) {
        result.add({
          'ingredient': ingredientName,
          'measure': measures[i] ?? '',
          'originalName': ingredientName,
          'imageUrl': getIngredientImageUrl(ingredientName),
        });
      }
    }
    return result;
  }

  String getFormattedInstructions() {
    if (strInstructions.isEmpty) return '';
    return strInstructions.split('. ').map((s) => '• $s').join('\n');
  }

  String getInstructionsForLanguage(String langCode) {
    try {
      // Verifica se temos as traduções
      if (translations != null) {
        // Converte as traduções para o tipo correto
        final Map<String, dynamic> translationsMap =
            Map<String, dynamic>.from(translations!);

        // Verifica se há instruções para o idioma selecionado
        if (translationsMap.containsKey(langCode)) {
          return translationsMap[langCode] ?? strInstructions;
        }

        // Se não encontrar no idioma selecionado, tenta em inglês
        return translationsMap['en'] ?? strInstructions;
      }
      return strInstructions;
    } catch (e) {
      Logger().e('Erro ao buscar instruções para drink $idDrink: $e');
      return strInstructions;
    }
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
      'Cocktail(id: $idDrink, name: $name, category: $category)';
}

enum ImageSize {
  small, // 100x100
  medium, // 350x350
  large // 700x700
}
