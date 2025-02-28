import 'package:app_netdrinks/repository/iba_drinks_repository.dart';
import 'package:app_netdrinks/services/iba_translation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class IBADetailController extends GetxController {
  final IBADrinksRepository repository;
  final logger = Logger();
  final currentVersion = Rx<String?>(null);
  final RxList<Map<String, String>> ingredients = <Map<String, String>>[].obs;
  final RxBool _loading = false.obs;
  final RxString _currentDrinkId = ''.obs;
  final translationService = Get.find<IBATranslationService>();

  IBADetailController(this.repository);

  bool get loading => _loading.value;
  String get currentDrinkId => _currentDrinkId.value;

  @override
  void onInit() {
    super.onInit();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        ingredients.clear();
        currentVersion.value = null;
        _currentDrinkId.value = '';
      } else {
        if (_currentDrinkId.isNotEmpty) {
          loadDrinkDetails(_currentDrinkId.value);
        }
      }
    });
  }

  Future<void> loadDrinkDetails(String drinkId) async {
    try {
      _loading.value = true;
      _currentDrinkId.value = drinkId;

      final drink = await repository.getDrinkById(drinkId);
      if (drink != null) {
        // Usando o serviço de tradução para obter ingredientes traduzidos
        final translatedIngredients =
            translationService.getIngredientsWithMeasures(drinkId);

        // Garantindo que todos os campos necessários estejam presentes
        final processedIngredients = translatedIngredients.map((ingredient) {
          return {
            'name': ingredient['name'] ?? '',
            'measure': ingredient['measure'] ?? '',
            'imageUrl': ingredient['imageUrl'] ?? ''
          };
        }).toList();

        ingredients.assignAll(processedIngredients);
        await loadMyVersion(drinkId);
      }
    } catch (e) {
      logger.e('Erro ao carregar detalhes: $e');
    } finally {
      _loading.value = false;
    }
  }

  Future<void> loadMyVersion(String drinkId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('ibaVersions')
          .doc('${user.uid}_$drinkId')
          .get();

      if (doc.exists) {
        currentVersion.value = doc.data()?['version'];
      }
    } catch (e) {
      logger.e('Erro ao carregar versão: $e');
    }
  }

  Future<void> saveMyVersion(String drinkId, String version) async {
    try {
      _loading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('ibaVersions')
          .doc('${user.uid}_$drinkId')
          .set({
        'userId': user.uid,
        'drinkId': drinkId,
        'version': version,
        'createdAt': FieldValue.serverTimestamp(),
      });

      currentVersion.value = version;
      Get.snackbar(
        'Sucesso',
        'Versão salva!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      logger.e('Erro ao salvar: $e');
    } finally {
      _loading.value = false;
    }
  }

  Future<void> deleteMyVersion(String drinkId) async {
    try {
      _loading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('ibaVersions')
          .doc('${user.uid}_$drinkId')
          .delete();

      currentVersion.value = null;
      Get.snackbar(
        'Sucesso',
        'Versão excluída!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      logger.e('Erro ao deletar: $e');
    } finally {
      _loading.value = false;
    }
  }

  @override
  void onClose() {
    ingredients.clear();
    currentVersion.close();
    _currentDrinkId.close();
    super.onClose();
  }
}
