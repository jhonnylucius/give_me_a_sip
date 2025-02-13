import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/controller/cocktail_list_controller.dart';
import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:app_netdrinks/services/likes_service.dart';
import 'package:app_netdrinks/services/locator_service.dart';
import 'package:app_netdrinks/services/translation_service.dart';
import 'package:get/get.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Translation Service
    Get.put(TranslationService(), permanent: true);

    // Repository - usando o já configurado no GetIt
    final repository = getIt<CocktailRepository>();
    Get.put(repository, permanent: true);

    // Controllers principais
    Get.put(
      CocktailListController(repository: repository),
      permanent: true,
    );

    Get.put(
      CocktailController(repository),
      permanent: true,
    );

    // Sistema de Likes
    Get.put(LikesService(), permanent: true);
    Get.put(LikesController(), permanent: true);
  }
}
