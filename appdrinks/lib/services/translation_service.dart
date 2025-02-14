import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class TranslationService extends GetxService {
  static TranslationService get to => Get.find();

  final _ingredientsMap = <String, Map<String, String>>{};
  final _drinksData = <String, Map<String, dynamic>>{};
  final _interfaceStrings = <String, Map<String, String>>{};
  final _currentLanguage = 'pt'.obs;

  Future<void> initialize() async {
    await Future.wait([
      _loadIngredientsMap(),
      _loadDrinksData(),
      _loadInterfaceStrings(),
    ]);
  }

  Future<void> _loadIngredientsMap() async {
    final file =
        await rootBundle.loadString('assets/data/ingredients_map.json');
    final Map<String, dynamic> data = json.decode(file);
    data.forEach((key, value) {
      _ingredientsMap[key] = Map<String, String>.from(value);
    });
  }

  Future<void> _loadDrinksData() async {
    final file = await rootBundle.loadString('assets/data/drinks_data.json');
    final Map<String, dynamic> data = json.decode(file);
    data.forEach((key, value) {
      _drinksData[key] = Map<String, dynamic>.from(value);
    });
  }

  Future<void> _loadInterfaceStrings() async {
    for (var lang in ['en', 'pt', 'es']) {
      final file = await rootBundle.loadString('assets/lang/$lang.json');
      final Map<String, dynamic> data = json.decode(file);
      _interfaceStrings[lang] = Map<String, String>.from(data);
    }
  }

  Future<void> setLanguage(String langCode) async {
    try {
      _currentLanguage.value = langCode;
      await Get.updateLocale(Locale(langCode));
    } catch (e) {
      Logger().e('Erro ao definir idioma: $e');
      rethrow;
    }
  }

  Future<String> translateToEnglish(String ingredient) async {
    // Procura no mapa de ingredientes existente
    for (var entry in _ingredientsMap.entries) {
      if (entry.value['pt']?.toLowerCase() == ingredient.toLowerCase() ||
          entry.value['es']?.toLowerCase() == ingredient.toLowerCase()) {
        return entry.key; // Retorna o nome em inglês (chave)
      }
    }
    return ingredient; // Se não encontrar, retorna o original
  }

  String translateIngredient(String ingredient) {
    return _ingredientsMap[ingredient]?[_currentLanguage.value] ?? ingredient;
  }

  String translateDrinkField(String drinkId, String field) {
    return _drinksData[drinkId]?[field]?[_currentLanguage.value] ??
        _drinksData[drinkId]?[field]?['en'] ??
        _drinksData[drinkId]?[field] ??
        '';
  }

  String getInterfaceString(String key) {
    return _interfaceStrings[_currentLanguage.value]?[key] ?? key;
  }
}
