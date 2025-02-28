import 'dart:convert';

import 'package:app_netdrinks/services/translation_service.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class IBATranslationService extends GetxService {
  static IBATranslationService get to => Get.find();

  final _ibaData = <String, dynamic>{}.obs;
  final _currentLanguage = 'pt'.obs;
  final List<String> supportedLanguages = ['en', 'pt', 'es', 'fr', 'it', 'de'];
  final logger = Logger();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  // Adicionando referência ao TranslationService principal
  final mainTranslationService = Get.find<TranslationService>();

  @override
  void onInit() async {
    super.onInit();
    await initialize();
  }

  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      final ibaFile =
          await rootBundle.loadString('assets/data/drinks_data_iba.json');
      final ibaData = json.decode(ibaFile);
      _ibaData.clear();
      _ibaData.addAll(ibaData);

      _isInitialized = true;
      logger.i('IBATranslationService inicializado com sucesso');
    } catch (e, stack) {
      logger.e('Erro na inicialização do IBATranslationService: $e\n$stack');
      rethrow;
    }
  }

  Map<String, Map<String, String>> categoryTranslations = {
    'The Unforgettables': {
      'en': 'The Unforgettables',
      'pt': 'Os Inesquecíveis',
      'es': 'Los Inolvidables',
      'fr': 'Les Inoubliables',
      'it': 'Gli Indimenticabili',
      'de': 'Die Unvergesslichen'
    },
    'Contemporary Classics': {
      'en': 'Contemporary Classics',
      'pt': 'Clássicos Contemporâneos',
      'es': 'Clásicos Contemporáneos',
      'fr': 'Classiques Contemporains',
      'it': 'Classici Contemporanei',
      'de': 'Zeitgenössische Klassiker'
    },
    'New Era': {
      'en': 'New Era',
      'pt': 'Nova Era',
      'es': 'Nueva Era',
      'fr': 'Nouvelle Ère',
      'it': 'Nuova Era',
      'de': 'Neue Ära'
    }
  };

  Map<String, Map<String, String>> alcoholicTranslations = {
    'Alcoholic': {
      'en': 'Alcoholic',
      'pt': 'Alcoólico',
      'es': 'Alcohólico',
      'fr': 'Alcoolisé',
      'it': 'Alcolico',
      'de': 'Alkoholisch'
    },
    'Non Alcoholic': {
      'en': 'Non Alcoholic',
      'pt': 'Não Alcoólico',
      'es': 'No Alcohólico',
      'fr': 'Non Alcoolisé',
      'it': 'Non Alcolico',
      'de': 'Alkoholfrei'
    }
  };

  String? translateField(String drinkId, String field) {
    try {
      final drinks = _ibaData['drinks'];
      if (drinks == null || drinks[drinkId] == null) {
        logger.w('Drink IBA não encontrado: $drinkId');
        return '';
      }

      final drink = drinks[drinkId];
      final currentLang = _currentLanguage.value;

      switch (field) {
        case 'category':
          final category = drink['category'] ?? '';
          return categoryTranslations[category]?[currentLang] ?? category;

        case 'alcoholic':
          final alcoholic = drink['alcoholic'] ?? '';
          return alcoholicTranslations[alcoholic]?[currentLang] ?? alcoholic;

        case 'glass':
          return drink['glass'] ?? '';

        case 'instructions':
          final instructions = drink['instructions'];
          return instructions[currentLang] ?? instructions['en'] ?? '';

        case 'ingredients':
          if (drink['ingredients'] is List) {
            final ingredients = drink['ingredients'] as List;
            return ingredients.map((i) => i['name']).join(', ');
          }
          return '';

        case 'measures':
          if (drink['ingredients'] is List) {
            final ingredients = drink['ingredients'] as List;
            return ingredients.map((i) => i['measure']).join(', ');
          }
          return '';

        case 'name':
          return drink['name'] ?? '';

        case 'videoUrl':
          return drink['videoUrl'] ?? '';
      }

      return drink[field]?.toString() ?? '';
    } catch (e) {
      logger.e('Erro ao traduzir campo IBA: $e');
      return '';
    }
  }

  List<Map<String, String>> getIngredientsWithMeasures(String drinkId) {
    try {
      final drinks = _ibaData['drinks'];
      if (drinks == null || drinks[drinkId] == null) return [];

      final drink = drinks[drinkId];
      final ingredients = drink['ingredients'] as List?;
      if (ingredients == null) return [];

      return ingredients.map((ingredient) {
        final originalName = (ingredient['name'] ?? '').toString();
        // Usando o serviço de tradução principal para traduzir o nome do ingrediente
        final translatedName =
            mainTranslationService.translateIngredient(originalName);

        return {
          'name': translatedName,
          'measure': (ingredient['measure'] ?? '').toString(),
          'imageUrl': (ingredient['imageUrl'] ?? '').toString(),
          'originalName':
              originalName // Mantendo o nome original para referência
        };
      }).toList();
    } catch (e) {
      logger.e('Erro ao obter ingredientes: $e');
      return [];
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      if (!supportedLanguages.contains(languageCode)) {
        throw Exception('Idioma não suportado: $languageCode');
      }

      _currentLanguage.value = languageCode;
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
