import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class TranslationService extends GetxService {
  static TranslationService get to => Get.find();

  final _drinksData = <String, dynamic>{}.obs; // Tornando observável
  final _interfaceStrings =
      <String, Map<String, dynamic>>{}.obs; // Tornando observável
  final _currentLanguage = 'pt'.obs;
  final List<String> supportedLanguages = ['en', 'pt', 'es', 'fr', 'it', 'de'];
  final logger = Logger();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initialize();
  }

  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      // Força carregamento do arquivo JSON
      final file = await rootBundle.loadString('assets/data/drinks_data.json');
      final data = json.decode(file);

      // Garante que os dados são carregados corretamente
      _drinksData.clear();
      _drinksData.addAll(data);

      // Carrega strings de interface
      await _loadInterfaceStrings();

      _isInitialized = true;
      logger.i('TranslationService inicializado com sucesso');
      logger.i('Drinks carregados: ${_drinksData["drinks"]?.length ?? 0}');
    } catch (e, stack) {
      logger.e('Erro na inicialização do TranslationService: $e');
      logger.e('Stack: $stack');
      rethrow;
    }
  }

  Future<void> _loadInterfaceStrings() async {
    for (var lang in supportedLanguages) {
      try {
        final file = await rootBundle.loadString('assets/lang/$lang.json');
        final data = json.decode(file);
        _interfaceStrings[lang] = Map<String, dynamic>.from(data);
      } catch (e) {
        logger.e('Erro ao carregar idioma $lang: $e');
      }
    }
  }

  String translateDrinkField(String drinkId, String field) {
    try {
      final drinks = _drinksData['drinks'];
      if (drinks == null || drinks[drinkId] == null) {
        logger.w('Drink não encontrado: $drinkId');
        return '';
      }

      final drink = drinks[drinkId];

      // Para campos que precisam de tradução específica
      switch (field) {
        case 'category':
          return _translateCategory(drink['category'] ?? '');
        case 'glass':
          return _translateGlass(drink['glass'] ?? '');
        case 'alcoholic':
          return _translateAlcoholic(drink['alcoholic'] ?? '');
        case 'instructions':
          final instructions = drink['instructions'];
          if (instructions != null) {
            return instructions[_currentLanguage.value] ??
                instructions['en'] ??
                '';
          }
      }

      return drink[field]?.toString() ?? '';
    } catch (e) {
      logger.e('Erro ao traduzir campo: $e');
      return '';
    }
  }

// No TranslationService, usamos métodos auxiliares:
  String _translateCategory(String category) {
    final categories = _drinksData['categories'];
    if (categories != null && categories[category] != null) {
      return categories[category][_currentLanguage.value] ??
          categories[category]['en'] ??
          category;
    }
    return category;
  }

  String _translateGlass(String glass) {
    final glasses = _drinksData['glasses'];
    if (glasses != null && glasses[glass] != null) {
      return glasses[glass][_currentLanguage.value] ??
          glasses[glass]['en'] ??
          glass;
    }
    return glass;
  }

  String _translateAlcoholic(String type) {
    return type.toLowerCase() == 'alcoholic'
        ? getInterfaceString('cocktails.alcoholic') ?? type
        : getInterfaceString('cocktails.non_alcoholic') ?? type;
  }

  String translateIngredient(String ingredient) {
    try {
      if (!_isInitialized) {
        logger.e('TranslationService não inicializado!');
        return ingredient;
      }

      final ingredients = _drinksData['ingredients'] as Map<String, dynamic>?;
      if (ingredients == null) return ingredient;

      final normalizedName = ingredient.toLowerCase();
      final ingredientData = ingredients[normalizedName];
      if (ingredientData == null) return ingredient;

      final translations =
          ingredientData['translations'] as Map<String, dynamic>?;
      if (translations == null) return ingredient;

      return translations[_currentLanguage.value] ??
          translations['en'] ??
          ingredient;
    } catch (e) {
      logger.e('Erro ao traduzir ingrediente: $e');
      return ingredient;
    }
  }

  Future<String> translateToEnglish(String text) async {
    try {
      if (!_isInitialized) {
        logger.e('TranslationService não inicializado!');
        return text;
      }

      // Para ingredientes
      final ingredients = _drinksData['ingredients'] as Map<String, dynamic>?;
      if (ingredients != null) {
        for (var entry in ingredients.entries) {
          final translations =
              entry.value['translations'] as Map<String, dynamic>?;
          if (translations != null) {
            for (var lang in translations.keys) {
              if (translations[lang].toString().toLowerCase() ==
                  text.toLowerCase()) {
                return translations['en'] ?? text;
              }
            }
          }
        }
      }

      return text;
    } catch (e) {
      logger.e('Erro ao traduzir para inglês: $e');
      return text;
    }
  }

  String translateTag(String tag) {
    try {
      // Normalizar a tag antes de buscar
      final normalizedTag = tag.toLowerCase().trim().replaceAll(' ', '_');
      // Buscar diretamente na seção 'tags' do arquivo de idiomas
      final interfaceStringsForLanguage =
          _interfaceStrings[_currentLanguage.value];
      if (interfaceStringsForLanguage != null &&
          interfaceStringsForLanguage['tags'] is Map) {
        final tags = interfaceStringsForLanguage['tags'] as Map;
        return tags[normalizedTag]?.toString() ?? tag;
      }
      return tag;
    } catch (e) {
      logger.e('Erro ao traduzir tag: $e');
      return tag;
    }
  }

  String getInterfaceString(String key) {
    try {
      if (!_isInitialized) {
        logger.e('TranslationService não inicializado!');
        return key;
      }

      final interfaceStringsForLanguage =
          _interfaceStrings[_currentLanguage.value];
      if (interfaceStringsForLanguage == null) {
        logger.w(
            'Nenhuma string de interface encontrada para o idioma: ${_currentLanguage.value}');
        return key;
      }

      // Lidar com chaves aninhadas (ex: 'cocktail_detail.ingredients')
      final keyParts = key.split('.');
      dynamic value = interfaceStringsForLanguage;

      for (var part in keyParts) {
        if (value is Map<String, dynamic>) {
          value = value[part];
        } else {
          logger.w('Caminho inválido para a chave: $key');
          return key;
        }
      }

      if (value == null) {
        logger.w(
            'Nenhuma tradução encontrada para a chave: $key no idioma ${_currentLanguage.value}');
        return key;
      }

      return value.toString();
    } catch (e, stack) {
      logger.e('Erro ao obter string de interface: $e');
      logger.e('Stack: $stack');
      return key;
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      if (!supportedLanguages.contains(languageCode)) {
        throw Exception('Idioma não suportado: $languageCode');
      }

      _currentLanguage.value = languageCode;
      Get.updateLocale(Locale(languageCode)); // Usar Get.updateLocale
      updateTranslations();
    } catch (e) {
      logger.e('Erro ao definir idioma: $e');
    }
  }

  void updateTranslations() {
    // Notifica os ouvintes sobre a mudança de idioma
    Get.forceAppUpdate();
  }

  String get currentLanguage => _currentLanguage.value;
}
