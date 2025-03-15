import 'package:app_netdrinks/widgets/cocktail_fill_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../contants/ranking_contants.dart';
import '../controller/ranking_controller.dart';
import '../models/cocktail.dart';
import '../models/drink_likes.dart';
import '../screens/cocktail_detail_screen.dart';
import '../widgets/ranking_list.dart';

class RankingScreen extends GetView<RankingController> {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(RankingConstants.rankingTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshRanking(),
          ),
        ],
      ),
      body: SafeArea(
        // Adicione SafeArea aqui
        child: Padding(
          // Adicione padding
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: RefreshIndicator(
            onRefresh: controller.refreshRanking,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CocktailFillLoading());
              }

              if (controller.error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.error.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.refreshRanking,
                        child: Text(
                          'Tentar Novamente',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.rankedDrinks.isEmpty) {
                return const Center(
                  child: Text('Nenhum drink encontrado no ranking'),
                );
              }

              return RankingList(drinks: controller.rankedDrinks);
            }),
          ),
        ),
      ),
    );
  }
}

class RankingCard extends StatelessWidget {
  final Cocktail cocktail;
  final DrinkLikes drinkLikes;
  final int rank;

  const RankingCard({
    super.key,
    required this.cocktail,
    required this.drinkLikes,
    required this.rank,
  });

  Color _getMedalColor() {
    switch (rank) {
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => CocktailDetailScreen(cocktail: cocktail)),
      child: Container(
        height: RankingConstants.cardHeight,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getMedalColor(),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.asset(
                cocktail.getDrinkImageUrl(), // Usando o mesmo método da home
                width: RankingConstants.rankingImageSize,
                height: RankingConstants.rankingImageSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    width: RankingConstants.rankingImageSize,
                    height: RankingConstants.rankingImageSize,
                    child: const Icon(Icons.error, color: Colors.redAccent),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$rank. ${cocktail.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Likes: ${drinkLikes.totalLikes}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      'Popularidade: ${drinkLikes.likePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
