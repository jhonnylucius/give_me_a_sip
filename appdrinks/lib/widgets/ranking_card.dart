import 'package:app_netdrinks/screens/cocktail_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../contants/ranking_contants.dart';
import '../models/cocktail.dart';
import '../models/drink_likes.dart';
import '../widgets/shared/widgets/heart_display.dart';

class RankingCard extends StatelessWidget {
  final Cocktail cocktail;
  final DrinkLikes drinkLikes;
  final int position;

  const RankingCard({
    super.key,
    required this.cocktail,
    required this.drinkLikes,
    required this.position,
  });

  Color _getMedalColor() {
    switch (position) {
      case 1:
        return Color(
            int.parse('0xFF${RankingConstants.topOneColor.substring(1)}'));
      case 2:
        return Color(
            int.parse('0xFF${RankingConstants.topTwoColor.substring(1)}'));
      case 3:
        return Color(
            int.parse('0xFF${RankingConstants.topThreeColor.substring(1)}'));
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => CocktailDetailScreen(cocktail: cocktail),
      ),
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
            Container(
              width: RankingConstants.rankingImageSize,
              height: RankingConstants.rankingImageSize,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(cocktail.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '#$position ${cocktail.name}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getMedalColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  HeartDisplay(
                    likes: drinkLikes.totalLikes,
                    color: _getMedalColor(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
