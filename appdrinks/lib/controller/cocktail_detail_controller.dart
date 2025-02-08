import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class CocktailController extends GetxController {
  final CocktailRepository repository;
  final _loading = false.obs;
  final _cocktails = <Cocktail>[].obs;

  CocktailController(this.repository);

  bool get loading => _loading.value;
  List<Cocktail> get cocktails => _cocktails;

  @override
  void onInit() {
    super.onInit();
    fetchAllCocktails();
  }

  Future<void> fetchAllCocktails() async {
    try {
      _loading.value = true;
      final result = await repository.getAllCocktails();
      _cocktails.assignAll(result);
      Logger().e('All cocktails fetched: ${_cocktails.length}');
    } catch (e) {
      Logger().e('Error fetching all cocktails: $e');
    } finally {
      _loading.value = false;
    }
  }

  // Atualize para usar um Rx<String?> para a versão atual
  final Rx<String?> currentVersion = Rx<String?>(null);

  Future<void> saveMyVersion(String cocktailId, String version) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      await FirebaseFirestore.instance
          .collection('myVersions')
          .doc('${user.uid}_$cocktailId')
          .set({
        'userId': user.uid,
        'cocktailId': cocktailId,
        'version': version,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Atualiza o estado local
      currentVersion.value = version;

      Get.snackbar(
        'Sucesso',
        'Sua versão foi salva!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Logger().e('Erro ao salvar versão: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível salvar sua versão',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadMyVersion(String cocktailId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('myVersions')
          .doc('${user.uid}_$cocktailId')
          .get();

      if (doc.exists && doc.data() != null) {
        currentVersion.value = doc.data()!['version'] as String;
      } else {
        currentVersion.value = null;
      }
    } catch (e) {
      Logger().e('Erro ao carregar versão: $e');
      currentVersion.value = null;
    }
  }

  Future<void> deleteMyVersion(String cocktailId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('myVersions')
          .doc('${user.uid}_$cocktailId')
          .delete();

      currentVersion.value = null;

      Get.snackbar(
        'Sucesso',
        'Versão excluída com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Logger().e('Erro ao deletar versão: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível excluir a versão',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
