import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/services/search_service.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  final SearchService _searchService = SearchService();
  final RxBool isLoading = false.obs;
  final RxList<Cocktail> searchResults = <Cocktail>[].obs;
  var popularResults = <Cocktail>[].obs;
  var maisRecentesResults = <Cocktail>[].obs;
  var dezAleatorioResults = <Cocktail>[].obs;
  var multiIngredientsResults = <Cocktail>[].obs;
  final RxList<Cocktail> noAlcoolResults = <Cocktail>[].obs;

  Future<void> searchByFirstLetter(String letter) async {
    try {
      isLoading.value = true;
      // Limpa os outros resultados
      popularResults.clear();
      maisRecentesResults.clear();
      dezAleatorioResults.clear();
      multiIngredientsResults.clear();
      noAlcoolResults.clear();

      searchResults.value = await _searchService.searchByFirstLetter(letter);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchMultiIngredients(String ingredients) async {
    try {
      isLoading.value = true;

      // Limpar outros resultados primeiro
      searchResults.clear();

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
      // Limpa os outros resultados
      searchResults.clear();
      maisRecentesResults.clear();
      dezAleatorioResults.clear();
      multiIngredientsResults.clear();
      noAlcoolResults.clear();

      popularResults.value = await _searchService.searchPopular();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchMaisRecentes() async {
    try {
      isLoading.value = true;
      // Limpa os outros resultados
      searchResults.clear();
      popularResults.clear();
      dezAleatorioResults.clear();
      multiIngredientsResults.clear();

      maisRecentesResults.value = await _searchService.searchMaisRecentes();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchDezAleatorio() async {
    try {
      isLoading.value = true;
      // Limpa os outros resultados
      searchResults.clear();
      popularResults.clear();
      maisRecentesResults.clear();
      multiIngredientsResults.clear();
      noAlcoolResults.clear();

      dezAleatorioResults.value = await _searchService.searchDezAleatorio();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchNoAlcool() async {
    try {
      isLoading.value = true;
      // Limpa os outros resultados
      searchResults.clear();
      popularResults.clear();
      maisRecentesResults.clear();
      multiIngredientsResults.clear();

      noAlcoolResults.value = await _searchService.searchNoAlcool();
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
