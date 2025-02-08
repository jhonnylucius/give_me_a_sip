import 'package:app_netdrinks/controller/cocktail_list_controller.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/cocktail_api.dart';
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton<CocktailApi>(() => CocktailApi());
  getIt.registerLazySingleton<CocktailRepository>(() => CocktailRepository(
      getIt<CocktailApi>(), Hive.box<Cocktail>('cocktailBox')));
  getIt.registerLazySingleton<CocktailListController>(
      () => CocktailListController(repository: getIt<CocktailRepository>()));
}
