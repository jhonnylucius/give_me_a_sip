import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/controller/cocktail_list_controller.dart';
import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/controller/ranking_controller.dart'; // Novo import
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:app_netdrinks/repository/ranking_repository.dart'; // Novo import
import 'package:app_netdrinks/services/azure_translation_service.dart';
import 'package:app_netdrinks/services/likes_service.dart';
import 'package:app_netdrinks/services/locator_service.dart';
import 'package:app_netdrinks/services/ranking_service.dart'; // Novo import
import 'package:app_netdrinks/services/translation_service.dart';
import 'package:get/get.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Translation Service (mantido)
    Get.put(TranslationService(), permanent: true);

    // Repository - usando o já configurado no GetIt (mantido)
    final repository = getIt<CocktailRepository>();
    Get.put(repository, permanent: true);

    // Controllers principais (mantidos)
    Get.put(
      CocktailListController(repository: repository),
      permanent: true,
    );

    Get.put(
      CocktailController(repository),
      permanent: true,
    );

    // Sistema de Likes (mantido)
    Get.put(LikesService(), permanent: true);
    Get.put(LikesController(Get.find<LikesService>()), permanent: true);

    // NOVO: Sistema de Ranking
    // 1. Repository
    Get.put<RankingRepository>(
      RankingRepository(cocktailRepository: repository),
      permanent: true,
    );

    // 2. Service
    Get.put<RankingService>(
      RankingService(),
      permanent: true,
    );

    // 3. Controller
    Get.put<RankingController>(
      RankingController(Get.find<RankingService>()),
      permanent: true,
    );
    Get.lazyPut(() => AzureTranslationService());
  }
}
