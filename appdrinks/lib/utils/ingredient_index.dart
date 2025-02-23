import 'package:app_netdrinks/models/cocktail.dart';

class IngredientIndex {
  final Map<String, Set<String>> _index = {};

  void buildIndex(List<Cocktail> cocktails) {
    _index.clear();

    for (var cocktail in cocktails) {
      // Verifica se ingredients é uma lista de strings
      if (cocktail.ingredients != null) {
        for (var ingredient in cocktail.ingredients) {
          // Usa o ingredient diretamente, já que é uma string
          final normalizedIngredient = ingredient?.toLowerCase().trim() ?? '';
          if (normalizedIngredient.isNotEmpty) {
            _index
                .putIfAbsent(normalizedIngredient, () => {})
                .add(cocktail.idDrink);
          }
        }
      }
    }
  }

  List<String> searchByIngredients(List<String> ingredients) {
    if (ingredients.isEmpty) return [];

    // Normaliza os ingredientes da busca
    final normalizedIngredients =
        ingredients.map((i) => i.toLowerCase().trim()).toSet();

    // Verifica se há algum ingrediente para buscar
    if (normalizedIngredients.isEmpty) return [];

    // Pega o primeiro conjunto de IDs
    var result = _index[normalizedIngredients.first] ?? {};

    // Intersecção com os demais ingredientes
    for (var ingredient in normalizedIngredients.skip(1)) {
      result = result.intersection(_index[ingredient] ?? {});
    }

    return result.toList();
  }

  bool get isIndexed => _index.isNotEmpty;
}
