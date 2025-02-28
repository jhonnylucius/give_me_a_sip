import 'package:app_netdrinks/models/iba_drinks.dart';
import 'package:app_netdrinks/repository/iba_drinks_repository.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class IBAListController extends GetxController {
  final IBADrinksRepository repository;
  final logger = Logger();
  final RxList<IBADrink> ibaDrinks = <IBADrink>[].obs;
  final RxBool _loading = false.obs;

  IBAListController(this.repository);

  bool get loading => _loading.value;

  Future<void> loadIBADrinks() async {
    try {
      _loading.value = true;
      logger.d('🔄 Carregando drinks IBA...');

      final drinks = await repository.loadIBADrinks();
      ibaDrinks.assignAll(drinks);

      logger.i('✅ ${drinks.length} drinks IBA carregados');
    } catch (e) {
      logger.e('❌ Erro ao carregar drinks IBA: $e');
      ibaDrinks.clear();
    } finally {
      _loading.value = false;
    }
  }

  @override
  void onClose() {
    ibaDrinks.clear();
    super.onClose();
  }
}
