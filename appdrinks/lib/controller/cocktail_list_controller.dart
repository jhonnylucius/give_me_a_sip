import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class CocktailListController extends GetxController {
  final CocktailRepository repository;
  final Logger logger = Logger();

  final _cocktails = <Cocktail>[].obs;
  List<Cocktail> get cocktails => _cocktails;

  final _favorites = <String>[].obs;
  List<String> get favorites => _favorites;

  CocktailListController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    loadFavorites(); // Carregar os favoritos do Hive
    getAllCocktails(); // Adicionar esta chamada
  }

  Future<void> getAllCocktails() async {
    try {
      logger.d('Fetching Cocktail...');
      final result = await repository.getAllCocktails();
      logger.d('Cocktail fetched: ${result.length}');
      _cocktails.assignAll(result);
    } catch (error) {
      logger.e('Error fetching cocktail: $error');
    }
  }

  bool isFavorite(String cocktailId) {
    return _favorites.contains(cocktailId);
  }

  void toggleFavorite(String cocktailId) {
    if (isFavorite(cocktailId)) {
      _favorites.remove(cocktailId);
    } else {
      _favorites.add(cocktailId);
    }
    saveFavorites(); // Salvar os favoritos no Hive
  }

  // Carregar os favoritos do Hive
  Future<void> loadFavorites() async {
    try {
      final box = await Hive.openBox<String>('favorites');
      _favorites.assignAll(box.values.toList());
      logger.i('Favoritos carregados do Hive: ${_favorites.length}');
    } catch (e) {
      logger.e('Erro ao carregar favoritos do Hive: $e');
    }
  }

  // Salvar os favoritos no Hive
  Future<void> saveFavorites() async {
    try {
      final box = await Hive.openBox<String>('favorites');
      await box.clear();
      await box.addAll(_favorites);
      logger.i('Favoritos salvos no Hive: ${_favorites.length}');
    } catch (e) {
      logger.e('Erro ao salvar favoritos no Hive: $e');
    }
  }
}
