import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/services/search_service.dart';
import 'package:app_netdrinks/services/translation_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SearchController extends GetxController {
  final SearchService _searchService;
  final TranslationService _translationService;
  final logger = Logger();

  final searchResults = <Cocktail>[].obs;
  final popularResults = <Cocktail>[].obs;
  final maisRecentesResults = <Cocktail>[].obs;
  final dezAleatorioResults = <Cocktail>[].obs;
  final multiIngredientsResults = <Cocktail>[].obs;
  final noAlcoolResults = <Cocktail>[].obs;
  final isLoading = false.obs;
  final currentSearchType = Rx<SearchType>(SearchType.none);
  final selectedIngredients = <String>[].obs;

  // Lista observável de ingredientes selecionados com seus nomes traduzidos
  final selectedIngredientsDisplay = <String>[].obs;

  SearchController(this._searchService, this._translationService);

  Future<void> searchByFirstLetter(String letter) async {
    if (letter.isEmpty) return;
    try {
      isLoading.value = true;
      currentSearchType.value = SearchType.letter;
      searchResults.clear();
      final results = await _searchService.searchByFirstLetter(letter);
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
      currentSearchType.value = SearchType.ingredients;
      multiIngredientsResults.clear();

      final translatedIngredients = await translateIngredients(ingredients);
      logger.d('Ingredientes traduzidos: $translatedIngredients');

      final results =
          await _searchService.searchMultiIngredients(translatedIngredients);
      multiIngredientsResults.assignAll(results);
    } catch (e) {
      logger.e('Erro na busca por ingredientes: $e');
      multiIngredientsResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> translateIngredients(String ingredients) async {
    try {
      var ingredientsList = ingredients
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      var translatedIngredients = await Future.wait(ingredientsList
          .map((i) => _translationService.translateToEnglish(i)));

      return translatedIngredients.join(',');
    } catch (e) {
      logger.e('Erro ao traduzir ingredientes: $e');
      return ingredients;
    }
  }

  Future<void> searchMaisRecentes() async {
    try {
      isLoading.value = true;
      currentSearchType.value = SearchType.recent;
      maisRecentesResults.clear();
      final results = await _searchService.getRecentCocktails();
      maisRecentesResults.assignAll(results);
    } catch (e) {
      logger.e('Erro na busca mais recentes: $e');
      maisRecentesResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchDezAleatorio() async {
    try {
      isLoading.value = true;
      currentSearchType.value = SearchType.random;
      dezAleatorioResults.clear();
      final results = await _searchService.getRandomCocktails(10);
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
      currentSearchType.value = SearchType.noAlcohol;
      noAlcoolResults.clear();
      final results = await _searchService.searchNoAlcool();
      noAlcoolResults.assignAll(results);
    } catch (e) {
      logger.e('Erro na busca sem álcool: $e');
      noAlcoolResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchPopular() async {
    try {
      isLoading.value = true;
      currentSearchType.value = SearchType.popular;
      popularResults.clear();
      final results = await _searchService.getPopularCocktails();
      popularResults.assignAll(results);
    } catch (e) {
      logger.e('Erro na busca popular: $e');
      popularResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCocktailDetailsAndNavigate(String drinkId) async {
    try {
      isLoading.value = true;
      final details = await _searchService.getById(drinkId);
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

  void clearSelection() {
    selectedIngredients.clear();
    selectedIngredientsDisplay.clear();
    multiIngredientsResults.clear();
    currentSearchType.value = SearchType.none;
  }

  void updateSelectedIngredients(List<String> ingredients,
      [bool search = false]) {
    selectedIngredients.value = ingredients;

    // Atualiza os nomes traduzidos para exibição
    final translationService = Get.find<TranslationService>();
    final currentLang = translationService.currentLanguage;

    selectedIngredientsDisplay.value = ingredients
        .map((ingredient) {
          return translationService.ingredientsData[ingredient]?[currentLang] ??
              ingredient;
        })
        .toList()
        .cast<String>();

    if (search && ingredients.isNotEmpty) {
      searchMultiIngredients(ingredients.join(','));
    }
  }

  List<Cocktail> getCurrentResults() {
    switch (currentSearchType.value) {
      case SearchType.letter:
        return searchResults;
      case SearchType.ingredients:
        return multiIngredientsResults;
      case SearchType.recent:
        return maisRecentesResults;
      case SearchType.random:
        return dezAleatorioResults;
      case SearchType.noAlcohol:
        return noAlcoolResults;
      case SearchType.popular:
        return popularResults;
      case SearchType.none:
        return popularResults;
    }
  }
}

enum SearchType {
  none,
  letter,
  ingredients,
  recent,
  random,
  noAlcohol,
  popular,
}
