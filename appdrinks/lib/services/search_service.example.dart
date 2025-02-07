import 'package:app_netdrinks/models/cocktail.dart';
import 'package:dio/dio.dart';

class SearchService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.thecocktaildb.com/api/json/v1/1',
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
    ),
  );

  Future<List<String>> listCategories() async {
    final response =
        await _dio.get('/list.php', queryParameters: {'c': 'list'});
    return (response.data['drinks'] as List)
        .map((item) => item['strCategory'] as String)
        .toList();
  }

  Future<List<String>> listGlasses() async {
    final response =
        await _dio.get('/list.php', queryParameters: {'g': 'list'});
    return (response.data['drinks'] as List)
        .map((item) => item['strGlass'] as String)
        .toList();
  }

  Future<List<String>> listIngredients() async {
    final response =
        await _dio.get('/list.php', queryParameters: {'i': 'list'});
    return (response.data['drinks'] as List)
        .map((item) => item['strIngredient1'] as String)
        .toList();
  }

  Future<List<String>> listAlcoholics() async {
    final response =
        await _dio.get('/list.php', queryParameters: {'a': 'list'});
    return (response.data['drinks'] as List)
        .map((item) => item['strAlcoholic'] as String)
        .toList();
  }

  Future<List<Cocktail>> filterByCategory(String category) async {
    final response =
        await _dio.get('/filter.php', queryParameters: {'c': category});
    return _parseCocktails(response.data);
  }

  Future<List<Cocktail>> filterByIngredient(String ingredient) async {
    final response =
        await _dio.get('/filter.php', queryParameters: {'i': ingredient});
    return _parseCocktails(response.data);
  }

  Future<List<Cocktail>> searchByFirstLetter(String letter) async {
    final response =
        await _dio.get('/search.php', queryParameters: {'f': letter});
    return _parseCocktails(response.data);
  }

  List<Cocktail> _parseCocktails(Map<String, dynamic> data) {
    if (data['drinks'] == null) return [];
    return (data['drinks'] as List)
        .map((item) => Cocktail.fromJson(item))
        .toList();
  }
}
