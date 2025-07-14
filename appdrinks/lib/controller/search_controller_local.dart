import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/services/search_service_local.dart';
import 'package:app_netdrinks/services/translation_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SearchControllerLocal extends GetxController {
  /// Busca um drink pelo id diretamente do serviço local
  Cocktail? getById(String id) {
    return _searchServiceLocal.getById(id);
  }

  final SearchServiceLocal _searchServiceLocal;
  final TranslationService _translationService;
  final logger = Logger();

  final searchResults = <Cocktail>[].obs;
  final dezAleatorioResults = <Cocktail>[].obs;
  final multiIngredientsResults = <Cocktail>[].obs;
  final noAlcoolResults = <Cocktail>[].obs;
  final isLoading = false.obs;
  final currentSearchType = Rx<SearchTypeLocal>(SearchTypeLocal.none);
  final selectedIngredients = <String>[].obs;
  final selectedIngredientsDisplay = <String>[].obs;

  SearchControllerLocal(this._searchServiceLocal, this._translationService);

  Future<void> searchByFirstLetter(String letter) async {
    if (letter.isEmpty) return;
    try {
      isLoading.value = true;
      currentSearchType.value = SearchTypeLocal.letter;
      searchResults.clear();
      final results = _searchServiceLocal.searchByFirstLetter(letter);
      searchResults.assignAll(results);
    } catch (e) {
      logger.e('Erro na busca por letra: $e');
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchMultiIngredients(String ingredients) async {
    if (ingredients.isEmpty) return;
    try {
      isLoading.value = true;
      currentSearchType.value = SearchTypeLocal.ingredients;
      multiIngredientsResults.clear();
      final ingredientsList = ingredients
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final results = _searchServiceLocal.searchByIngredients(ingredientsList);
      multiIngredientsResults.assignAll(results);
    } catch (e) {
      logger.e('Erro na busca por ingredientes: $e');
      multiIngredientsResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchDezAleatorio() async {
    try {
      isLoading.value = true;
      currentSearchType.value = SearchTypeLocal.random;
      dezAleatorioResults.clear();
      final results = _searchServiceLocal.getRandomDrinks(10);
      dezAleatorioResults.assignAll(results);
    } catch (e) {
      logger.e('Erro na busca aleatória: $e');
      dezAleatorioResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchNoAlcool() async {
    try {
      isLoading.value = true;
      currentSearchType.value = SearchTypeLocal.noAlcohol;
      noAlcoolResults.clear();
      final results = _searchServiceLocal.searchNoAlcohol();
      noAlcoolResults.assignAll(results);
    } catch (e) {
      logger.e('Erro na busca sem álcool: $e');
      noAlcoolResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void clearSelection() {
    selectedIngredients.clear();
    selectedIngredientsDisplay.clear();
    multiIngredientsResults.clear();
    currentSearchType.value = SearchTypeLocal.none;
  }

  void updateSelectedIngredients(List<String> ingredients,
      [bool search = false]) {
    selectedIngredients.value = ingredients;
    final currentLang = _translationService.currentLanguage;
    selectedIngredientsDisplay.value = ingredients
        .map((ingredient) =>
            _translationService.ingredientsData[ingredient]?[currentLang] ??
            ingredient)
        .toList()
        .cast<String>();
    if (search && ingredients.isNotEmpty) {
      searchMultiIngredients(ingredients.join(','));
    }
  }

  Future<void> fetchCocktailDetailsAndNavigate(String drinkId) async {
    try {
      isLoading.value = true;
      final details = getById(drinkId);
      if (details != null) {
        Get.toNamed('/cocktail-detail', arguments: details);
      } else {
        Get.snackbar("Erro", "Não foi possível carregar detalhes do drink.");
      }
    } catch (e) {
      logger.e('Erro ao carregar detalhes: $e');
      Get.snackbar("Erro", "Ocorreu um erro ao carregar os detalhes.");
    } finally {
      isLoading.value = false;
    }
  }

  List<Cocktail> getCurrentResults() {
    switch (currentSearchType.value) {
      case SearchTypeLocal.letter:
        return searchResults;
      case SearchTypeLocal.ingredients:
        return multiIngredientsResults;
      case SearchTypeLocal.random:
        return dezAleatorioResults;
      case SearchTypeLocal.noAlcohol:
        return noAlcoolResults;
      case SearchTypeLocal.none:
        return [];
    }
  }
}

enum SearchTypeLocal {
  none,
  letter,
  ingredients,
  random,
  noAlcohol,
}
