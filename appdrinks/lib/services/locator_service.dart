import 'package:app_netdrinks/controller/cocktail_list_controller.dart';
import 'package:app_netdrinks/models/cocktail_api.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton<CocktailApi>(() => CocktailApi());
  getIt.registerLazySingleton<CocktailListController>(
      () => CocktailListController());
}
