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
    Logger().d('Ingrediente recebido: $ingredient');

    // Primeiro verificar se o mapa foi carregado
    if (_ingredientsMap.isEmpty) {
      await _loadIngredientsMap();
    }

    Logger().d('Procurando tradução para: ${ingredient.toLowerCase()}');

    // Procurar em todas as entradas do mapa
    for (var entry in _ingredientsMap.entries) {
      // Log para debug
      Logger().d('Verificando entrada: ${entry.key} -> ${entry.value}');

      // Verificar se o ingrediente corresponde à tradução em português
      if (entry.value['pt']?.toLowerCase() == ingredient.toLowerCase()) {
        Logger().d('Encontrou tradução PT->EN: ${entry.key}');
        return entry.key;
      }

      // Verificar se o ingrediente corresponde à tradução em espanhol
      if (entry.value['es']?.toLowerCase() == ingredient.toLowerCase()) {
        Logger().d('Encontrou tradução ES->EN: ${entry.key}');
        return entry.key;
      }
    }

    Logger().d('Nenhuma tradução encontrada, retornando original: $ingredient');
    return ingredient;
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
