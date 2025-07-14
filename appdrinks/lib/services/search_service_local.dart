import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/services/translation_service.dart';
import 'dart:math';
import 'package:get/get.dart';

/// Serviço de busca 100% offline usando os dados locais já carregados pelo TranslationService.
class SearchServiceLocal {
  /// Busca um drink pelo id
  Cocktail? getById(String id) {
    final drinks =
        _translationService.drinksData['drinks'] as Map<String, dynamic>?;
    if (drinks == null) return null;
    final data = drinks[id];
    if (data == null) return null;
    return Cocktail.fromJson(data);
  }

  final TranslationService _translationService = Get.find<TranslationService>();

  /// Busca drinks pelo nome (primeira letra)
  List<Cocktail> searchByFirstLetter(String letter) {
    final drinks =
        _translationService.drinksData['drinks'] as Map<String, dynamic>?;
    if (drinks == null) return [];
    return drinks.values
        .map((e) => Cocktail.fromJson(e))
        .where(
            (c) => (c.strDrink).toLowerCase().startsWith(letter.toLowerCase()))
        .toList();
  }

  /// Busca drinks que contenham TODOS os ingredientes selecionados
  List<Cocktail> searchByIngredients(List<String> selectedIngredients) {
    final drinks =
        _translationService.drinksData['drinks'] as Map<String, dynamic>?;
    if (drinks == null) return [];
    return drinks.values
        .map((e) => Cocktail.fromJson(e))
        .where((c) => selectedIngredients.every((ing) => c.ingredients
            .map((i) => (i['name'] ?? '').toLowerCase())
            .contains(ing.toLowerCase())))
        .toList();
  }

  /// Busca drinks não alcoólicos
  List<Cocktail> searchNoAlcohol() {
    final drinks =
        _translationService.drinksData['drinks'] as Map<String, dynamic>?;
    if (drinks == null) return [];
    return drinks.values
        .map((e) => Cocktail.fromJson(e))
        .where(
            (c) => (c.strAlcoholic ?? '').toLowerCase().contains('non alcohol'))
        .toList();
  }

  /// Retorna 10 drinks aleatórios
  List<Cocktail> getRandomDrinks([int count = 10]) {
    final drinks =
        _translationService.drinksData['drinks'] as Map<String, dynamic>?;
    if (drinks == null) return [];
    final all = drinks.values.map((e) => Cocktail.fromJson(e)).toList();
    all.shuffle(Random());
    return all.take(count).toList();
  }
}
