import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../models/cocktail.dart';
import '../models/drink_likes.dart';
import '../services/ranking_service.dart';

class RankingController extends GetxController {
  final RankingService _rankingService;
  final _logger = Logger();

  var isLoading = false.obs;
  var error = ''.obs;
  var rankedDrinks = <(Cocktail, DrinkLikes)>[].obs;

  RankingController(this._rankingService);

  @override
  void onInit() {
    super.onInit();
    refreshRanking(); // Remove o delay, não é necessário
  }

  Future<void> refreshRanking() async {
    try {
      isLoading.value = true;
      error.value = '';
      _logger.d('Iniciando atualização do ranking...');

      // Remove a verificação de autenticação que estava causando loop
      final drinks = await _rankingService.getTopDrinks(forceRefresh: true);
      rankedDrinks.assignAll(drinks);
    } catch (e) {
      _logger.e('Erro ao atualizar ranking: $e');
      error.value = 'Tente novamente em alguns instantes...';
    } finally {
      isLoading.value = false;
    }
  }
}
