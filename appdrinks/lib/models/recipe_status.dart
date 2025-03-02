import 'package:app_netdrinks/enums/recipe_type.dart';

class RecipeStatus {
  final RecipeType type;
  final String drinkId;
  final String? ibaReference;

  const RecipeStatus({
    required this.type,
    required this.drinkId,
    this.ibaReference,
  });
}
