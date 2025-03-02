import 'package:app_netdrinks/enums/recipe_type.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/iba_drinks.dart';
import 'package:app_netdrinks/models/recipe_status.dart';
import 'package:app_netdrinks/utils/recipe_validator.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class RecipeValidationService extends GetxService {
  final logger = Logger();
  final _validatedRecipes = <String, RecipeStatus>{}.obs;

  String _normalizeNames(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  Future<RecipeStatus> validateRecipe(
      Cocktail cocktail, List<IBADrink> ibaDrinks) async {
    try {
      final normalizedCocktailName = _normalizeNames(cocktail.name);

      // Usando tryWhere ao invés de firstWhere para evitar exceções
      final matchingIBA = ibaDrinks.cast<IBADrink?>().firstWhere(
            (iba) =>
                iba != null &&
                _normalizeNames(iba.name) == normalizedCocktailName,
            orElse: () => null,
          );

      // Se não encontrou no IBA, é uma receita original
      if (matchingIBA == null) {
        logger.d('Receita não encontrada no IBA: ${cocktail.name}');
        return _createOriginalStatus(cocktail.idDrink);
      }

      logger.d('Validando receita IBA: ${cocktail.name}');

      // Compara os ingredientes
      final cocktailIngredients = cocktail.getIngredientsWithMeasures();
      final ibaIngredients = matchingIBA.getIngredientsWithMeasures();

      if (cocktailIngredients.isEmpty || ibaIngredients.isEmpty) {
        logger.d('Lista de ingredientes vazia');
        return _createOriginalStatus(cocktail.idDrink);
      }

      final isOfficial = RecipeValidator.compareIngredients(
        cocktailIngredients,
        ibaIngredients,
      );

      if (isOfficial) {
        logger.d('Receita oficial encontrada!');
        return _createOfficialStatus(cocktail.idDrink, matchingIBA.id);
      } else {
        logger.d('Receita é uma variação do IBA');
        return _createVariationStatus(cocktail.idDrink, matchingIBA.id);
      }
    } catch (e) {
      logger.e('Erro ao validar receita: $e');
      return _createOriginalStatus(cocktail.idDrink);
    }
  }

  // Métodos auxiliares para criar status
  RecipeStatus _createOriginalStatus(String drinkId) {
    final status = RecipeStatus(
      type: RecipeType.original,
      drinkId: drinkId,
    );
    _validatedRecipes[drinkId] = status;
    return status;
  }

  RecipeStatus _createOfficialStatus(String drinkId, String ibaId) {
    final status = RecipeStatus(
      type: RecipeType.official,
      drinkId: drinkId,
      ibaReference: ibaId,
    );
    _validatedRecipes[drinkId] = status;
    return status;
  }

  RecipeStatus _createVariationStatus(String drinkId, String ibaId) {
    final status = RecipeStatus(
      type: RecipeType.variation,
      drinkId: drinkId,
      ibaReference: ibaId,
    );
    _validatedRecipes[drinkId] = status;
    return status;
  }
}
