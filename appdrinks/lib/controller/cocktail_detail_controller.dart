import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/my_version.dart';
import 'package:app_netdrinks/repository/cocktail_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CocktailController extends GetxController {
  final CocktailRepository repository;
  final _loading = false.obs;
  final _cocktails = <Cocktail>[].obs;
  final _favorites = <String>[].obs;

  CocktailController(this.repository);

  bool get loading => _loading.value;
  List<Cocktail> get cocktails => _cocktails;
  List<String> get favorites => _favorites;

  @override
  void onInit() {
    super.onInit();
    fetchAllCocktails(); // Carrega todos os drinks
    loadFavorites();
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

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favoriteCocktails') ?? [];
    _favorites.assignAll(favoriteIds);
  }

  Future<void> toggleFavorite(String cocktailId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds = [..._favorites];

    if (favoriteIds.contains(cocktailId)) {
      favoriteIds.remove(cocktailId);
    } else {
      favoriteIds.add(cocktailId);
    }

    await prefs.setStringList('favoriteCocktails', favoriteIds);
    _favorites.assignAll(favoriteIds);
  }

  bool isFavorite(String cocktailId) {
    return _favorites.contains(cocktailId);
  }

  List<Cocktail> getFavoriteCocktails() {
    return _cocktails.where((c) => _favorites.contains(c.idDrink)).toList();
  }

  final Rxn<MyVersion> myVersion = Rxn<MyVersion>();

  Future<void> saveMyVersion(String drinkId, String text) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = FirebaseFirestore.instance
          .collection('myVersions')
          .doc('${user.uid}_$drinkId');

      final version = MyVersion(
        id: '${user.uid}_$drinkId',
        drinkId: drinkId,
        userId: user.uid,
        text: text,
        createdAt: DateTime.now(),
      );

      await docRef.set(version.toMap());
      myVersion.value = version;
    } catch (e) {
      Logger().e('Error saving my version: $e');
    }
  }

  Future<void> loadMyVersion(String drinkId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = FirebaseFirestore.instance
          .collection('myVersions')
          .doc('${user.uid}_$drinkId');

      final doc = await docRef.get();
      if (doc.exists) {
        myVersion.value = MyVersion.fromMap(doc.data()!);
      } else {
        myVersion.value = null;
      }
    } catch (e) {
      Logger().e('Error loading my version: $e');
    }
  }

  Future<void> deleteMyVersion(String drinkId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('myVersions')
          .doc('${user.uid}_$drinkId')
          .delete();

      myVersion.value = null;
    } catch (e) {
      Logger().e('Error deleting my version: $e');
    }
  }
}
