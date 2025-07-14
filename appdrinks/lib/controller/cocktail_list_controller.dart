import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/recipe_status.dart';
import 'package:app_netdrinks/repository/cocktail_repository_local.dart';
import 'package:app_netdrinks/repository/iba_drinks_repository.dart';
import 'package:app_netdrinks/services/recipe_validation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class CocktailListController extends GetxController {
  final CocktailRepositoryLocal repository;
  final Logger logger = Logger();

  final _cocktails = <Cocktail>[].obs;
  List<Cocktail> get cocktails => _cocktails;

  final _favorites = <String>[].obs;
  List<String> get favorites => _favorites;

  final _recipeValidationService = Get.find<RecipeValidationService>();
  final _recipeStatuses = <String, RecipeStatus>{}.obs;

  CocktailListController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    loadCocktails(); // Adicionar esta chamada

    // Adicionar listener para mudanças de auth
    FirebaseAuth.instance.authStateChanges().listen((user) {
      logger.d('Estado de autenticação mudou: ${user?.uid ?? 'deslogado'}');
      if (user == null) {
        _favorites.clear(); // Limpa favoritos ao deslogar
      } else {
        loadFavorites(); // Carrega favoritos do novo usuário
      }
    });
  }

  bool isFavorite(String cocktailId) {
    return _favorites.contains(cocktailId);
  }

  Future<void> toggleFavorite(String cocktailId) async {
    if (isFavorite(cocktailId)) {
      _favorites.remove(cocktailId);
    } else {
      _favorites.add(cocktailId);
    }
    saveFavorites();

    final likesController = Get.find<LikesController>();
    await likesController.toggleLike(cocktailId); // Salvar no Firestore
    // Salvar os favoritos no Hive
  }

  // Carregar os favoritos do Hive
  Future<void> loadFavorites() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _favorites.clear();
        return;
      }

      final boxName = 'favorites_${user.uid}';
      final box = await Hive.openBox<String>(boxName);
      _favorites.assignAll(box.values.toList());
      logger.i(
          'Favoritos carregados para usuário ${user.uid}: ${_favorites.length}');
    } catch (e) {
      logger.e('Erro ao carregar favoritos do Hive: $e');
    }
  }

  // Salvar os favoritos no Hive
  Future<void> saveFavorites() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final boxName = 'favorites_${user.uid}';
      final box = await Hive.openBox<String>(boxName);
      await box.clear();
      await box.addAll(_favorites);
      logger
          .i('Favoritos salvos para usuário ${user.uid}: ${_favorites.length}');
    } catch (e) {
      logger.e('Erro ao salvar favoritos no Hive: $e');
    }
  }

  Future<void> loadCocktails() async {
    try {
      final drinks = await repository.getAllCocktails();

      // Ordenação simples e direta
      drinks.sort((a, b) {
        final nameA =
            a.name.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
        final nameB =
            b.name.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
        return nameA.compareTo(nameB);
      });

      _cocktails.value = drinks;
      await _validateRecipes();
    } catch (e) {
      logger.e('Erro ao carregar cocktails: $e');
    }
  }

  Future<void> _validateRecipes() async {
    try {
      final ibaRepository = Get.find<IBADrinksRepository>();
      final ibaDrinks = await ibaRepository.loadIBADrinks();

      // Filtra apenas os drinks que não são IBA do menu geral
      for (var drink in _cocktails) {
        logger.d('Validando drink: ${drink.name}');
        final status =
            await _recipeValidationService.validateRecipe(drink, ibaDrinks);
        _recipeStatuses[drink.idDrink] = status;
        logger.d('Status para ${drink.name}: ${status.type}');
      }
    } catch (e) {
      logger.e('Erro ao validar receitas: $e');
    }
  }

  RecipeStatus? getRecipeStatus(String drinkId) {
    return _recipeStatuses[drinkId];
  }
}
