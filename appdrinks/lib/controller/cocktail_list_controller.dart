import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    getAllCocktails(); // Adicionar esta chamada

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
}
