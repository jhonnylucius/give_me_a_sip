import 'package:app_netdrinks/repository/cocktail_repository_local.dart';
import 'package:app_netdrinks/services/search_service_local.dart';
import 'package:app_netdrinks/services/translation_service.dart';
import 'package:app_netdrinks/controller/search_controller_local.dart';
import 'package:get_it/get_it.dart';

final getItLocal = GetIt.instance;

Future<void> setupLocatorLocal() async {
  // Registra TranslationService como singleton
  getItLocal
      .registerLazySingleton<TranslationService>(() => TranslationService());

  // Registra SearchServiceLocal como singleton
  getItLocal
      .registerLazySingleton<SearchServiceLocal>(() => SearchServiceLocal());

  getItLocal.registerLazySingleton<CocktailRepositoryLocal>(
    () => CocktailRepositoryLocal(),
  );
  getItLocal.registerLazySingleton<ICocktailRepositoryLocal>(
    () => getItLocal<CocktailRepositoryLocal>(),
  );

  // Registra SearchControllerLocal como singleton
  getItLocal.registerLazySingleton<SearchControllerLocal>(
    () => SearchControllerLocal(
      getItLocal<SearchServiceLocal>(),
      getItLocal<TranslationService>(),
    ),
  );
}
