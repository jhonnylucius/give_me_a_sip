import 'package:app_netdrinks/services/translation_service.dart';
import 'package:get/get.dart';

class TranslationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TranslationService(), permanent: true);
  }
}
