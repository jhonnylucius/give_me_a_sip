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

  SearchController(this._searchService, this._translationService);

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        searchPopular(),
        searchMaisRecentes(),
        searchDezAleatorio(),
        searchNoAlcool(),
      ]);
    } catch (e) {
      logger.e('Erro ao carregar dados iniciais: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchByFirstLetter(String letter) async {
    if (letter.isEmpty) return;
    try {
      isLoading.value = true;
      final language = Get.locale?.languageCode ?? 'pt';
      final results =
          await _searchService.searchByFirstLetter(letter, language);
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
      final language = Get.locale?.languageCode ?? 'pt';
      var ingredientsList = ingredients
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      var translatedIngredients = await Future.wait(ingredientsList
          .map((i) => _translationService.translateToEnglish(i)));

      final results = await _searchService.searchMultiIngredients(
          translatedIngredients.join(','), language);
      multiIngredientsResults.assignAll(results);
    } catch (e) {
      logger.e('Erro na busca por ingredientes: $e');
      multiIngredientsResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchMaisRecentes() async {
    try {
      isLoading.value = true;
      final language = Get.locale?.languageCode ?? 'pt';
      final results = await _searchService.getRecentCocktails(language);
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
      final language = Get.locale?.languageCode ?? 'pt';
      final results = await _searchService.getRandomCocktails(10, language);
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
      final language = Get.locale?.languageCode ?? 'pt';
      final results = await _searchService.searchNoAlcool(language);
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
      final language = Get.locale?.languageCode ?? 'pt';
      final results = await _searchService.getPopularCocktails(language);
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
      final language = Get.locale?.languageCode ?? 'pt';
      final details = await _searchService.getById(drinkId, language);
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
}
