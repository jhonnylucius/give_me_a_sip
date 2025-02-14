import 'package:flutter/material.dart';

import '../models/cocktail.dart';
import '../models/drink_likes.dart';
import 'ranking_card.dart';

class RankingList extends StatelessWidget {
  final List<(Cocktail, DrinkLikes)> drinks;

  const RankingList({
    super.key,
    required this.drinks,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drinks.length,
      itemBuilder: (context, index) {
        final (cocktail, drinkLikes) = drinks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RankingCard(
            cocktail: cocktail,
            drinkLikes: drinkLikes,
            position: index + 1,
          ),
        );
      },
    );
  }
}
