import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/cocktail_api.dart';
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    final api = CocktailApi();
    final cocktailBox = Hive.box<Cocktail>('cocktailBox');
    final repository = CocktailRepository(api, cocktailBox);

    Get.put(CocktailController(repository));
  }
}
