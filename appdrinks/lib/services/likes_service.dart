import 'package:app_netdrinks/models/drink_likes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:logger/logger.dart';

class LikesService extends GetxService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _logger = Logger();

  // Remova a primeira declaração duplicada do método e mantenha apenas esta versão
  Future<List<String>> getUserLikedDrinks(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('drinks_likes')
          .where('users_liked', arrayContains: userId)
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      _logger.e('Erro ao buscar drinks curtidos: $e');
      return [];
    }
  }

  // Toggle like com tratamento de erros robusto
  Future<void> toggleLike(String drinkId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _logger.w('Tentativa de like sem usuário autenticado');
      return;
    }

    try {
      final docRef = _firestore.collection('drinks_likes').doc(drinkId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          // Primeiro like do drink
          _logger.d('Criando novo documento de likes para drink: $drinkId');
          transaction.set(docRef, {
            'drinkId': drinkId,
            'total_likes': 1, // Começa com 1
            'users_liked': [userId]
          });
        } else {
          final data = doc.data()!;
          final currentUsers = List<String>.from(data['users_liked'] ?? []);

          if (currentUsers.contains(userId)) {
            // Usuário já deu like, vai remover
            _logger.d('Removendo like do drink: $drinkId');
            transaction.update(docRef, {
              'total_likes': (data['total_likes'] ?? 1) - 1, // Decrementa 1
              'users_liked': FieldValue.arrayRemove([userId])
            });
          } else {
            // Usuário não deu like, vai adicionar
            _logger.d('Adicionando like ao drink: $drinkId');
            transaction.update(docRef, {
              'total_likes': (data['total_likes'] ?? 0) + 1, // Incrementa 1
              'users_liked': FieldValue.arrayUnion([userId])
            });
          }
        }
      });
    } catch (e) {
      _logger.e('Erro ao atualizar likes: $e');
      throw Exception('Falha ao atualizar like: $e');
    }
  }

  // Obter total de likes de um drink
  Future<int> getTotalLikes(String drinkId) async {
    try {
      final doc =
          await _firestore.collection('drinks_likes').doc(drinkId).get();

      if (!doc.exists) return 0;

      final drinkLikes = DrinkLikes.fromJson(doc.data()!);
      return drinkLikes.totalLikes;
    } catch (e) {
      _logger.e('Erro ao obter total de likes: $e');
      return 0;
    }
  }

  Stream<DrinkLikes> getLikesStream(String drinkId) {
    try {
      return _firestore
          .collection('drinks_likes')
          .doc(drinkId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          return DrinkLikes(drinkId: drinkId, totalLikes: 0, usersLiked: []);
        }

        final data = snapshot.data()!;
        return DrinkLikes(
          drinkId: drinkId,
          totalLikes: data['total_likes'] ?? 0,
          usersLiked: List<String>.from(data['users_liked'] ?? []),
        );
      });
    } catch (e) {
      _logger.e('Erro ao obter stream de likes: $e');
      // Retorna um stream com valor zero em caso de erro
      return Stream.value(
          DrinkLikes(drinkId: drinkId, totalLikes: 0, usersLiked: []));
    }
  }

  @override
  void onInit() {
    super.onInit();
    _logger.d('LikesService inicializado');
  }

  @override
  void onClose() {
    _logger.d('LikesService finalizado');
    super.onClose();
  }
}
