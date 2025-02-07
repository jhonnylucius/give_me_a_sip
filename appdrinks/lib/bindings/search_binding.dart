import 'package:app_netdrinks/controller/search_controller.dart';
import 'package:app_netdrinks/services/search_service.dart';
import 'package:get/get.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchService());
    Get.lazyPut(() => SearchController());
  }
}
