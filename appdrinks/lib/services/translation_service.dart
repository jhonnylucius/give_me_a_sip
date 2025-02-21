import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class TranslationService extends GetxService {
  static TranslationService get to => Get.find();

  final _drinksData = <String, dynamic>{};
  final _interfaceStrings = <String, Map<String, dynamic>>{};
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
      // Debug
      logger.d('Traduzindo campo $field do drink $drinkId');
      logger.d('Dados carregados: ${_drinksData.keys.join(", ")}');

      if (!_isInitialized) {
        logger.e('TranslationService não inicializado!');
        return '';
      }

      final drinks = _drinksData['drinks'] as Map<String, dynamic>?;
      if (drinks == null) {
        logger.e('Nó "drinks" não encontrado no JSON');
        return '';
      }

      final drink = drinks[drinkId];
      if (drink == null) {
        logger.w('Drink não encontrado: $drinkId');
        return '';
      }

      if (field == 'instructions') {
        final instructions = drink['instructions'] as Map<String, dynamic>?;
        if (instructions != null) {
          final translated =
              instructions[_currentLanguage.value] ?? instructions['en'];
          logger.d('Instrução traduzida: $translated');
          return translated ?? '';
        }
      }

      return drink[field]?.toString() ?? '';
    } catch (e, stack) {
      logger.e('Erro ao traduzir campo $field do drink $drinkId: $e');
      logger.e('Stack: $stack');
      return '';
    }
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

  String getInterfaceString(String key) {
    try {
      if (!_isInitialized) {
        logger.e('TranslationService não inicializado!');
        return key;
      }

      return _interfaceStrings[_currentLanguage.value]?[key]?.toString() ?? key;
    } catch (e) {
      logger.e('Erro ao obter string de interface: $e');
      return key;
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      if (!supportedLanguages.contains(languageCode)) {
        throw Exception('Idioma não suportado: $languageCode');
      }

      _currentLanguage.value = languageCode;
      await Get.updateLocale(Locale(languageCode));
      updateTranslations();
    } catch (e) {
      logger.e('Erro ao definir idioma: $e');
    }
  }

  void updateTranslations() {
    Get.forceAppUpdate();
  }

  String get currentLanguage => _currentLanguage.value;
}
