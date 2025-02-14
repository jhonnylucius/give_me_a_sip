import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../models/cocktail.dart';
import '../models/drink_likes.dart';
import '../repository/cocktail_repository.dart';

class RankingRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger;
  final CocktailRepository _cocktailRepository;

  RankingRepository({
    FirebaseFirestore? firestore,
    Logger? logger,
    required CocktailRepository cocktailRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger ?? Logger(),
        _cocktailRepository = cocktailRepository;

  Future<List<(Cocktail, DrinkLikes)>> getTopDrinks({int limit = 10}) async {
    try {
      _logger.d('Iniciando busca de top drinks com prioridade na API...');

      // Inicia busca paralela dos cocktails para otimização
      final cocktailsFuture = _cocktailRepository.getAllCocktails();

      // Busca dados do Firestore
      final likesSnapshot = await _firestore
          .collection('drinks_likes')
          .orderBy('total_likes', descending: true)
          .limit(limit)
          .get();

      _logger
          .d('Documentos encontrados no ranking: ${likesSnapshot.docs.length}');

      // Aguarda resultado dos cocktails da busca paralela
      final allCocktails = await cocktailsFuture;
      _logger.d('Total de cocktails carregados: ${allCocktails.length}');

      // Processa os resultados
      List<(Cocktail, DrinkLikes)> rankedDrinks = [];

      // Atualização em paralelo do Firestore
      final batch = _firestore.batch();
      var needsUpdate = false;

      for (var doc in likesSnapshot.docs) {
        try {
          final drinkId = doc.id;
          final cocktail = allCocktails.firstWhere(
            (c) => c.idDrink == drinkId,
          );

          final drinkLikes = DrinkLikes.fromJson({
            'drinkId': drinkId,
            'total_likes': doc.data()['total_likes'] ?? 0,
            'users_liked': doc.data()['users_liked'] ?? [],
          });

          // Verifica se precisa atualizar no Firestore
          if (doc.data()?['last_updated'] == null) {
            needsUpdate = true;
            batch.update(doc.reference, {
              'last_updated': FieldValue.serverTimestamp(),
              ...drinkLikes.toJson(),
            });
          }

          rankedDrinks.add((cocktail, drinkLikes));
          _logger.d(
              'Drink processado: ${cocktail.name} com ${drinkLikes.totalLikes} likes');
        } catch (e) {
          _logger.e('Erro ao processar drink ${doc.id}: $e');
          continue;
        }
      }

      // Executa atualização em batch se necessário
      if (needsUpdate) {
        _logger.d('Executando atualização em batch no Firestore...');
        await batch.commit();
      }

      _logger.d('Total de drinks rankeados: ${rankedDrinks.length}');
      return rankedDrinks;
    } catch (e) {
      _logger.e('Erro ao buscar ranking de drinks: $e');
      throw Exception('Falha ao carregar ranking: $e');
    }
  }
}
