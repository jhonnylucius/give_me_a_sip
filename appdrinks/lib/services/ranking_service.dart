import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../models/cocktail.dart';
import '../models/drink_likes.dart';
import '../repository/ranking_repository.dart';

class RankingService extends GetxService {
  final RankingRepository _repository;
  final Logger _logger = Logger();

  List<(Cocktail, DrinkLikes)>? _cachedTopDrinks;
  DateTime? _lastFetch;

  RankingService() : _repository = Get.find<RankingRepository>();

  Future<void> _calculatePercentages(
      List<(Cocktail, DrinkLikes)> drinks) async {
    if (drinks.isEmpty) return;

    // Calcula o total de likes de todos os drinks no ranking
    final totalLikes = drinks
        .map((d) => d.$2.totalLikes)
        .reduce((sum, likes) => sum + likes)
        .toDouble();

    // Se houver pelo menos um like, calcula a porcentagem baseada no total
    if (totalLikes > 0) {
      for (var (_, drinkLikes) in drinks) {
        // Calcula a porcentagem individual baseada no total de likes
        drinkLikes.likePercentage = (drinkLikes.totalLikes / totalLikes) * 100;
      }
    } else {
      // Se não houver likes, distribui igualmente entre os drinks presentes
      final equalPercentage = 100.0 / drinks.length;
      for (var (_, drinkLikes) in drinks) {
        drinkLikes.likePercentage = equalPercentage;
      }
    }

    // Verifica se a soma das porcentagens é 100%
    double totalPercentage =
        drinks.fold(0.0, (sum, drink) => sum + drink.$2.likePercentage);

    // Ajusta pequenas diferenças de arredondamento se necessário
    if (totalPercentage != 100 && drinks.isNotEmpty) {
      final adjustment = (100 - totalPercentage) / drinks.length;
      for (var (_, drinkLikes) in drinks) {
        drinkLikes.likePercentage += adjustment;
      }
    }

    _logger.d(
        'Porcentagens calculadas. Total: ${totalPercentage.toStringAsFixed(2)}%');
  }

  Future<List<(Cocktail, DrinkLikes)>> getTopDrinks(
      {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cachedTopDrinks != null && _lastFetch != null) {
        final difference = DateTime.now().difference(_lastFetch!);
        if (difference.inMinutes < 5) {
          _logger.d('Retornando drinks do cache');
          return _cachedTopDrinks!;
        }
      }

      _logger.d('Buscando top drinks...');
      final drinks = await _repository.getTopDrinks(limit: 10);
      await _calculatePercentages(drinks);
      _logger.d('Drinks encontrados: ${drinks.length}');

      _cachedTopDrinks = drinks;
      _lastFetch = DateTime.now();

      return drinks;
    } catch (e) {
      _logger.e('Erro ao buscar ranking: $e');
      rethrow;
    }
  }
}
