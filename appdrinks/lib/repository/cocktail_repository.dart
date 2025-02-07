import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/cocktail_api.dart';
import 'package:hive/hive.dart';

class CocktailRepository {
  final CocktailApi _api;
  final Box<Cocktail> _cache;

  CocktailRepository(this._api, this._cache);

  Future<List<Cocktail>> getAllCocktails() async {
    try {
      // Verificar se há dados em cache
      if (_cache.isNotEmpty) {
        return _cache.values.toList();
      }

      // Buscar todos os cocktails da API
      final cocktails = await _api.getAllCocktails();

      // Salvar no cache
      await _cache.clear();
      await _cache.addAll(cocktails);

      return cocktails;
    } catch (e) {
      throw Exception('Falha ao carregar todos os cocktails: $e');
    }
  }

  Future<List<Cocktail>> getPopularCocktails() async {
    try {
      // Tentar pegar do cache primeiro
      if (_cache.isNotEmpty) {
        return _cache.values.toList();
      }

      // Se não tiver cache, buscar todos da API
      final cocktails = await _api.getAllCocktails();

      // Salvar no cache
      await _cache.clear();
      await _cache.addAll(cocktails);

      return cocktails;
    } catch (e) {
      throw Exception('Falha ao carregar cocktails: $e');
    }
  }

  Future<List<Cocktail>> searchByName(String name) async {
    try {
      // Buscar direto da API, sem cache
      return await _api.searchByName(name);
    } catch (e) {
      throw Exception('Falha ao buscar cocktails: $e');
    }
  }

  Future<List<Cocktail>> filterByCategory(String category) async {
    try {
      return await _api.filterByCategory(category);
    } catch (e) {
      throw Exception('Falha ao filtrar por categoria: $e');
    }
  }

  Future<List<Cocktail>> filterByIngredient(String ingredient) async {
    try {
      return await _api.filterByIngredient(ingredient);
    } catch (e) {
      throw Exception('Falha ao filtrar por ingrediente: $e');
    }
  }

  Future<Cocktail> getRandomCocktail() async {
    try {
      return await _api.getRandomCocktail();
    } catch (e) {
      throw Exception('Falha ao buscar cocktail aleatório: $e');
    }
  }

  Future<Cocktail> showSearchDialog() async {
    try {
      return await _api.getRandomCocktail();
    } catch (e) {
      throw Exception('Falha ao buscar cocktail aleatório: $e');
    }
  }

  // Métodos para gerenciar cache
  Future<void> clearCache() async {
    await _cache.clear();
  }

  Future<void> updateCache(List<Cocktail> cocktails) async {
    await _cache.clear();
    await _cache.addAll(cocktails);
  }

  bool get hasCachedData => _cache.isNotEmpty;
}
