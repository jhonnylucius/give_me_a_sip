import 'dart:async';

import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/cocktail_api.dart';
import 'package:app_netdrinks/services/locator_service.dart';
import 'package:logger/logger.dart';

class CocktailListController {
  final api = getIt<CocktailApi>();
  final Logger logger = Logger();

  final _controller = StreamController<List<Cocktail>>();
  Stream<List<Cocktail>> get stream => _controller.stream;

  void init() {
    getCocktail();
  }

  Future<void> getCocktail() async {
    try {
      logger.d('Fetching Cocktail...');
      var result = await api.searchByName(' ');
      logger.d('Cocktail fetched: ${result.length}');
      _controller.sink.add(result);
    } catch (error) {
      logger.e('Error fetching cocktail: $error');
      _controller.sink.addError(error);
    }
  }

  Future<void> searchCocktail(Map<String, String?> filters) async {
    try {
      logger.d('Searching cocktail with filters: $filters');
      var result =
          await api.searchByName(''); // Ajustar para usar filtros na API
      if (filters['name'] != null && filters['name']!.isNotEmpty) {
        result = result
            .where((cocktail) => cocktail.name
                .toLowerCase()
                .contains(filters['name']!.toLowerCase()))
            .toList();
      }
      if (filters['ingredients'] != null &&
          filters['ingredients']!.isNotEmpty) {
        result = result
            .where((cocktail) =>
                cocktail.ingredients.toString().toLowerCase() ==
                filters['ingredients']!.toLowerCase())
            .toList();
      }
      if (filters['category'] != null && filters['category']!.isNotEmpty) {
        result = result
            .where((cocktail) =>
                cocktail.category.toLowerCase() ==
                filters['category']!.toLowerCase())
            .toList();
      }
      logger.d('Cocktail found: ${result.length}');
      _controller.sink.add(result);
    } catch (error) {
      logger.e('Error searching Cocktail: $error');
      _controller.sink.addError(error);
    }
  }
}
