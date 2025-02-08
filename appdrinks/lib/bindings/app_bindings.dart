import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/controller/cocktail_list_controller.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/cocktail_api.dart';
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:app_netdrinks/services/locator_service.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Primeiro registramos o repository
    Get.lazyPut(() => CocktailRepository(
          getIt<CocktailApi>(),
          Hive.box<Cocktail>('cocktailBox'),
        ));

    // Depois registramos os controllers
    Get.lazyPut(() => CocktailListController(repository: Get.find()));
    Get.lazyPut(
      () => CocktailController(Get.find()),
      fenix: true, // Isso faz o controller "renascer" quando destruído
    );
  }
}
