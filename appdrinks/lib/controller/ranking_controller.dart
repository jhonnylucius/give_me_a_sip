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
    refreshRanking();
  }

  Future<void> refreshRanking() async {
    try {
      isLoading.value = true;
      error.value = '';
      _logger.d('Iniciando atualização do ranking...');

      final drinks = await _rankingService.getTopDrinks(forceRefresh: true);

      if (drinks.isEmpty) {
        _logger.w('Nenhum drink encontrado no ranking');
      } else {
        _logger.d('Drinks carregados: ${drinks.length}');
        _logger.d('Primeiro drink: ${drinks.first.$1.name}');
      }

      rankedDrinks.assignAll(drinks);
    } catch (e) {
      _logger.e('Erro ao atualizar ranking: $e');
      error.value = 'Erro ao carregar o ranking: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
