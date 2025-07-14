import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/services/translation_service.dart';
import 'package:get/get.dart';
import 'dart:math';

/// Interface do repositório local
abstract class ICocktailRepositoryLocal {
  List<Cocktail> getAllCocktails();
  List<Cocktail> searchByName(String name);
  List<Cocktail> filterByCategory(String category);
  List<Cocktail> filterByIngredient(String ingredient);
  Cocktail? getRandomCocktail();
  Cocktail? getById(String id);
}

/// Implementação do repositório local para acessar drinks diretamente do JSON carregado pelo TranslationService.
class CocktailRepositoryLocal implements ICocktailRepositoryLocal {
  final TranslationService _translationService = Get.find<TranslationService>();

  @override
  List<Cocktail> getAllCocktails() {
    final drinks =
        _translationService.drinksData['drinks'] as Map<String, dynamic>?;
    if (drinks == null) return [];
    return drinks.values.map((e) => Cocktail.fromJson(e)).toList();
  }

  @override
  List<Cocktail> searchByName(String name) {
    final all = getAllCocktails();
    return all
        .where((c) => (c.strDrink).toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  @override
  List<Cocktail> filterByCategory(String category) {
    final all = getAllCocktails();
    return all
        .where((c) => (c.category).toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  List<Cocktail> filterByIngredient(String ingredient) {
    final all = getAllCocktails();
    return all
        .where((c) => (c.ingredients as List).any(
            (i) => (i['name'] ?? '').toLowerCase() == ingredient.toLowerCase()))
        .toList();
  }

  @override
  Cocktail? getRandomCocktail() {
    final all = getAllCocktails();
    if (all.isEmpty) return null;
    return all[Random().nextInt(all.length)];
  }

  @override
  Cocktail? getById(String id) {
    final drinks =
        _translationService.drinksData['drinks'] as Map<String, dynamic>?;
    if (drinks == null) return null;
    final data = drinks[id];
    if (data == null) return null;
    return Cocktail.fromJson(data);
  }
}
