import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/controller/cocktail_list_controller.dart';
import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/controller/ranking_controller.dart';
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:app_netdrinks/repository/ranking_repository.dart';
import 'package:app_netdrinks/services/likes_service.dart';
import 'package:app_netdrinks/services/locator_service.dart';
import 'package:app_netdrinks/services/ranking_service.dart';
import 'package:app_netdrinks/services/search_service.dart';
import 'package:app_netdrinks/services/translation_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AppBindings implements Bindings {
  final logger = Logger();

  @override
  void dependencies() async {
    try {
      // Inicializa o TranslationService primeiro
      final translationService = TranslationService();
      await translationService.initialize();
      Get.put<TranslationService>(translationService, permanent: true);
      logger.i('TranslationService inicializado');

      // Services
      Get.put<SearchService>(SearchService(), permanent: true);
      logger.i('SearchService registrado');

      // Repository
      final repository = getIt<CocktailRepository>();
      Get.put(repository, permanent: true);
      logger.i('CocktailRepository registrado');

      // Controllers
      Get.put(CocktailListController(repository: repository), permanent: true);
      Get.put(CocktailController(repository), permanent: true);
      logger.i('Controllers principais registrados');

      // Likes System
      final likesService = LikesService();
      likesService.onInit();
      Get.put(likesService, permanent: true);
      Get.put(LikesController(likesService), permanent: true);
      logger.i('Sistema de likes inicializado');

      // Ranking System
      final rankingRepo = RankingRepository(cocktailRepository: repository);
      Get.put<RankingRepository>(rankingRepo, permanent: true);

      final rankingService = RankingService();
      Get.put<RankingService>(rankingService, permanent: true);

      Get.put<RankingController>(
        RankingController(rankingService),
        permanent: true,
      );
      logger.i('Sistema de ranking inicializado');

      logger.i('✅ Todas as dependências registradas com sucesso');
    } catch (e) {
      logger.e('❌ Erro ao registrar dependências: $e');
      rethrow; // Permite que o erro seja tratado em níveis superiores
    }
  }
}
