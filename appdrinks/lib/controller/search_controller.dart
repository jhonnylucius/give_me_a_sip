import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/services/search_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SearchController extends GetxController {
  final SearchService _searchService = SearchService();

  // RxLists para armazenar os resultados
  final searchResults = <Cocktail>[].obs;
  final popularResults = <Cocktail>[].obs;
  final maisRecentesResults = <Cocktail>[].obs;
  final dezAleatorioResults = <Cocktail>[].obs;
  final multiIngredientsResults = <Cocktail>[].obs;
  final noAlcoolResults = <Cocktail>[].obs;

  final isLoading = false.obs;

  // Método para limpar todos os resultados
  void _clearAllResults() {
    searchResults.clear();
    popularResults.clear();
    maisRecentesResults.clear();
    dezAleatorioResults.clear();
    multiIngredientsResults.clear();
    noAlcoolResults.clear();
  }

  // Método para busca sem álcool
  Future<void> searchNoAlcool() async {
    try {
      isLoading.value = true;
      _clearAllResults(); // Limpa todos os resultados anteriores
      final results = await _searchService.searchNoAlcool();
      noAlcoolResults.value = results;
    } catch (e) {
      Logger().e('Erro na busca sem álcool: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Método para busca aleatória
  Future<void> searchDezAleatorio() async {
    try {
      isLoading.value = true;
      _clearAllResults(); // Limpa todos os resultados anteriores
      final results = await _searchService.searchDezAleatorio();
      dezAleatorioResults.value = results;
    } catch (e) {
      Logger().e('Erro na busca aleatória: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Método para obter todos os resultados
  List<Cocktail> get allResults {
    if (noAlcoolResults.isNotEmpty) return noAlcoolResults;
    if (dezAleatorioResults.isNotEmpty) return dezAleatorioResults;
    if (popularResults.isNotEmpty) return popularResults;
    if (maisRecentesResults.isNotEmpty) return maisRecentesResults;
    if (multiIngredientsResults.isNotEmpty) return multiIngredientsResults;
    return searchResults;
  }

  Future<void> searchByFirstLetter(String letter) async {
    try {
      isLoading.value = true;
      _clearAllResults(); // Limpa todos os resultados
      searchResults.value = await _searchService.searchByFirstLetter(letter);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchMultiIngredients(String ingredients) async {
    try {
      isLoading.value = true;
      _clearAllResults(); // Limpa todos os resultados primeiro

      // Realizar pesquisa apenas em inglês
      searchResults.value =
          await _searchService.searchMultiIngredients(ingredients);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchPopular() async {
    try {
      isLoading.value = true;
      _clearAllResults(); // Limpa todos os resultados
      popularResults.value = await _searchService.searchPopular();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchMaisRecentes() async {
    try {
      isLoading.value = true;
      _clearAllResults(); // Limpa todos os resultados
      maisRecentesResults.value = await _searchService.searchMaisRecentes();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCocktailDetailsAndNavigate(String drinkId) async {
    try {
      isLoading.value = true;
      final details = await _searchService.getCocktailDetails(drinkId);
      if (details != null) {
        Get.toNamed('/cocktail-detail', arguments: details);
      } else {
        Get.snackbar("Erro", "Não foi possível carregar detalhes do drink.");
      }
    } finally {
      isLoading.value = false;
    }
  }
}
