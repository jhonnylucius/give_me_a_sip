import 'package:app_netdrinks/controller/iba_list_controller.dart';
import 'package:app_netdrinks/repository/iba_drinks_repository.dart';
import 'package:app_netdrinks/services/iba_translation_service.dart';
import 'package:get/get.dart';

class IBABindings extends Bindings {
  @override
  void dependencies() {
    Get.put(IBATranslationService(), permanent: true);
    Get.lazyPut(() => IBADrinksRepository());
    Get.lazyPut(() => IBAListController(Get.find<IBADrinksRepository>()));
  }
}
