import 'package:app_netdrinks/models/drink_likes.dart';
import 'package:app_netdrinks/services/likes_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class LikesController extends GetxController {
  final _likesService = Get.find<LikesService>();
  final _logger = Logger();
  final _likedDrinks = <String, bool>{}.obs;
  final RxList<String> userLikedDrinks = <String>[].obs;

  LikesController(LikesService likesService);

  @override
  void onInit() {
    super.onInit();
    _logger.d('LikesController inicializado');
    // Adicionar listener para mudanças de auth
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _logger.d('Estado de autenticação mudou: ${user?.uid ?? 'deslogado'}');
      loadUserLikedDrinks(); // Recarrega quando muda o usuário
    });
  }

  Stream<DrinkLikes> getLikesStream(String drinkId) {
    return _likesService.getLikesStream(drinkId);
  }

  Future<void> toggleLike(String drinkId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Atualiza estado local
      final currentState = _likedDrinks[drinkId] ?? false;
      _likedDrinks[drinkId] = !currentState;

      if (!currentState) {
        userLikedDrinks.add(drinkId);
      } else {
        userLikedDrinks.remove(drinkId);
      }

      // Atualiza Firebase
      await _likesService.toggleLike(drinkId);
    } catch (e) {
      // Reverte estado local em caso de erro
      _likedDrinks[drinkId] = !(_likedDrinks[drinkId] ?? false);
      _logger.e('Erro ao alternar like: $e');
    }
  }

  bool isLikedRx(String drinkId) {
    return _likedDrinks[drinkId] ?? false;
  }

  Future<void> loadUserLikedDrinks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _likedDrinks.clear();
      userLikedDrinks.clear();
      return;
    }

    try {
      final likedDrinks = await _likesService.getUserLikedDrinks(user.uid);
      _likedDrinks.clear();
      for (var drinkId in likedDrinks) {
        _likedDrinks[drinkId] = true;
      }
      userLikedDrinks.assignAll(likedDrinks);
    } catch (e) {
      _logger.e('Erro ao carregar drinks curtidos: $e');
    }
  }
}
