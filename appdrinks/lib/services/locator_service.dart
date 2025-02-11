import 'package:app_netdrinks/adapters/cocktail_adapter.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/cocktail_api.dart';
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  try {
    // Inicializa o Hive
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);

    // Registra os adaptadores
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CocktailAdapter());
    }

    // Registra as dependências em ordem
    getIt.registerLazySingleton<CocktailApi>(() => CocktailApi());

    final box = await Hive.openBox<Cocktail>('cocktails');
    getIt.registerSingleton<Box<Cocktail>>(box);

    getIt.registerLazySingleton<CocktailRepository>(() => CocktailRepository(
          getIt<CocktailApi>(),
          getIt<Box<Cocktail>>(),
        ));

    print('Locator configurado com sucesso');
  } catch (e, stack) {
    print('Erro na configuração do Locator: $e');
    print('Stack: $stack');
    rethrow; // Importante: Relança o erro para tratamento adequado
  }
}
