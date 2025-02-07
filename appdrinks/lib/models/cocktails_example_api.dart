import 'package:app_netdrinks/models/cocktail.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class CocktailsExampleApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.thecocktaildb.com/api/json/v1/1',
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
    ),
  );
  final Logger logger = Logger();

  Future<List<String>> listCategories() async {
    try {
      logger.d('Listando categorias...');
      final response =
          await _dio.get('/list.php', queryParameters: {'c': 'list'});
      final List<dynamic> items = response.data['drinks'] ?? [];
      return items
          .whereType<Map<String, dynamic>>()
          .map((item) => item['strCategory'] as String)
          .toList();
    } catch (e) {
      logger.e('Erro ao buscar lista de categorias: $e');
      rethrow;
    }
  }

  Future<List<String>> listGlasses() async {
    try {
      logger.d('Listando copos...');
      final response =
          await _dio.get('/list.php', queryParameters: {'g': 'list'});
      final List<dynamic> items = response.data['drinks'] ?? [];
      return items
          .whereType<Map<String, dynamic>>()
          .map((item) => item['strGlass'] as String)
          .toList();
    } catch (e) {
      logger.e('Erro ao buscar lista de copos: $e');
      rethrow;
    }
  }

  Future<List<String>> listIngredients() async {
    try {
      logger.d('Listando ingredientes...');
      final response =
          await _dio.get('/list.php', queryParameters: {'i': 'list'});
      final List<dynamic> items = response.data['drinks'] ?? [];
      return items
          .whereType<Map<String, dynamic>>()
          .map((item) => item['strIngredient1'] as String)
          .toList();
    } catch (e) {
      logger.e('Erro ao buscar lista de ingredientes: $e');
      rethrow;
    }
  }

  Future<List<String>> listAlcoholics() async {
    try {
      logger.d('Listando tipos de alcoólicos...');
      final response =
          await _dio.get('/list.php', queryParameters: {'a': 'list'});
      final List<dynamic> items = response.data['drinks'] ?? [];
      return items
          .whereType<Map<String, dynamic>>()
          .map((item) => item['strAlcoholic'] as String)
          .toList();
    } catch (e) {
      logger.e('Erro ao buscar lista de alcoólicos: $e');
      rethrow;
    }
  }

  Future<List<Cocktail>> searchByName(String name) async {
    try {
      logger.d('Buscando cocktails por nome: $name');
      final response =
          await _dio.get('/search.php', queryParameters: {'s': name});
      return _parseCocktailList(response.data);
    } catch (e) {
      logger.e('Erro na busca por nome: $e');
      rethrow;
    }
  }

  Future<List<Cocktail>> filterByCategory(String? category) async {
    try {
      // Melhor tratamento para categoria nula ou vazia
      if (category == null || category.trim().isEmpty) {
        logger.w('Categoria nula ou vazia, retornando lista vazia.');
        return [];
      }

      // Log para debug
      logger.d('Filtrando por categoria: "$category"');

      // Garantir que a categoria seja uma string válida
      final sanitizedCategory = category.trim();

      // Fazer a requisição
      final response = await _dio.get(
        '/filter.php',
        queryParameters: {'c': sanitizedCategory},
      );

      // Verificar se a resposta contém dados
      if (response.data == null || response.data['drinks'] == null) {
        logger
            .w('Resposta da API não contém drinks para a categoria: $category');
        return [];
      }

      // Parse da resposta
      return _parseCocktailList(response.data);
    } catch (e, stackTrace) {
      // Log detalhado do erro
      logger.e('Erro ao filtrar por categoria: $category',
          error: e, stackTrace: stackTrace);

      // Se for um erro específico de tipo nulo, retornar lista vazia
      if (e is TypeError &&
          e.toString().contains("'Null' is not a subtype of type 'String'")) {
        return [];
      }

      rethrow;
    }
  }

  Future<List<Cocktail>> filterByGlass(String glass) async {
    try {
      if (glass.isEmpty) {
        throw ArgumentError('Copo não pode ser nulo ou vazio');
      }
      logger.d('Filtrando por copo: $glass');
      final response =
          await _dio.get('/filter.php', queryParameters: {'g': glass});
      return _parseCocktailList(response.data);
    } catch (e) {
      logger.e('Erro ao filtrar por copo: $e');
      rethrow;
    }
  }

  Future<List<Cocktail>> filterByIngredient(String ingredient) async {
    try {
      if (ingredient.isEmpty) {
        throw ArgumentError('Ingrediente não pode ser nulo ou vazio');
      }
      logger.d('Filtrando por ingrediente: $ingredient');
      final response =
          await _dio.get('/filter.php', queryParameters: {'i': ingredient});
      return _parseCocktailList(response.data);
    } catch (e) {
      logger.e('Erro ao filtrar por ingrediente: $e');
      rethrow;
    }
  }

  Future<List<Cocktail>> filterByAlcoholic(String alcoholic) async {
    try {
      if (alcoholic.isEmpty) {
        throw ArgumentError('Alcoólico não pode ser nulo ou vazio');
      }
      logger.d('Filtrando por alcoólico: $alcoholic');
      final response =
          await _dio.get('/filter.php', queryParameters: {'a': alcoholic});
      return _parseCocktailList(response.data);
    } catch (e) {
      logger.e('Erro ao filtrar por alcoólico: $e');
      rethrow;
    }
  }

  Future<Cocktail> getRandomCocktail() async {
    try {
      logger.d('Buscando cocktail aleatório...');
      final response = await _dio.get('/random.php');
      final drinks = _parseCocktailList(response.data);
      return drinks.first;
    } catch (e) {
      logger.e('Erro ao buscar cocktail aleatório: $e');
      rethrow;
    }
  }

  List<Cocktail> _parseCocktailList(Map<String, dynamic> data) {
    final drinks = data['drinks'] as List?;
    if (drinks == null) {
      return [];
    }
    return drinks
        .whereType<Map<String, dynamic>>()
        .map((drink) => Cocktail.fromJson(drink))
        .toList();
  }

  Future<List<Cocktail>> getPopularCocktails() async {
    try {
      logger.d('Buscando cocktails populares...');
      final response = await _dio.get('/popular.php');
      return _parseCocktailList(response.data);
    } catch (e) {
      logger.e('Erro ao buscar populares: $e');
      rethrow;
    }
  }

  Future<List<Cocktail>> getAllCocktails() async {
    try {
      logger.d('Buscando todos os cocktails...');
      List<Cocktail> allCocktails = [];

      // 1. Buscar drinks populares (Premium)
      try {
        final popularDrinks = await getPopularCocktails();
        allCocktails.addAll(popularDrinks);
      } catch (e) {
        logger.w('Erro ao buscar drinks populares: $e');
      }

      // 2. Buscar por letra do alfabeto

      try {
        for (String letter in 'abcdefghijklmnopqrstuvwxyz'.split('')) {
          final response =
              await _dio.get('/search.php', queryParameters: {'f': letter});
          if (response.data['drinks'] != null) {
            allCocktails.addAll(_parseCocktailList(response.data));
          }
        }
      } catch (e) {
        logger.w('Erro ao buscar por letra: $e');
      }

      // 3. Buscar por categorias
      final categories = await listCategories();
      for (String category in categories) {
        try {
          final categoryDrinks = await filterByCategory(category);
          allCocktails.addAll(categoryDrinks);
        } catch (e) {
          logger.w('Erro ao buscar categoria $category: $e');
        }
      }

      // Remover duplicatas
      final uniqueDrinks = allCocktails.toSet().toList();
      logger.i('Total de cocktails únicos encontrados: ${uniqueDrinks.length}');

      return uniqueDrinks;
    } catch (e) {
      logger.e('Erro ao buscar todos os cocktails: $e');
      rethrow;
    }
  }
}
