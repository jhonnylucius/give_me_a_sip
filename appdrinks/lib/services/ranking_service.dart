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
      final drinks = await _repository.getTopDrinks(limit: 50);
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
