import 'dart:async';

import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/cocktail_api.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class CocktailRepository {
  final CocktailApi _api;
  final Box<Cocktail> _cache;
  final Logger logger = Logger();

  // Adicionar um flag para controle de cache
  bool _isCacheLoading = false;

  CocktailRepository(this._api, this._cache);

  Future<List<Cocktail>> getAllCocktails() async {
    try {
      // Verificar cache primeiro
      if (_cache.isNotEmpty) {
        return _cache.values.toList();
      }

      // Evitar múltiplas chamadas à API enquanto carrega
      if (_isCacheLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
        return getAllCocktails();
      }

      _isCacheLoading = true;

      // Carregar da API em paralelo
      final cocktails = await Future.wait([
        _api.getPopularCocktails(),
        _api.getAllCocktails(),
      ]).then((results) {
        // Mesclar resultados e remover duplicatas
        final allCocktails = {...results[0], ...results[1]}.toList();
        return allCocktails;
      });

      // Atualizar cache em background
      updateCache(cocktails).then((_) => logger.i('Cache atualizado'));

      _isCacheLoading = false;
      return cocktails;
    } catch (e) {
      _isCacheLoading = false;
      rethrow;
    }
  }

  Future<void> updateCache(List<Cocktail> cocktails) async {
    try {
      // Limpar cache antigo
      await _cache.clear();

      // Usar putAll ao invés de múltiplos puts
      final Map<dynamic, Cocktail> entries = {
        for (var cocktail in cocktails) cocktail.idDrink: cocktail
      };
      await _cache.putAll(entries);
    } catch (e) {
      logger.e('Erro ao atualizar cache: $e');
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

  bool get hasCachedData => _cache.isNotEmpty;
}
