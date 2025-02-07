import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CocktailCard extends StatelessWidget {
  final Cocktail cocktail;
  final String user;
  final double cardWidth = 300; // Largura fixa do card
  final double cardHeight = 200; // Altura fixa do card

  CocktailCard({super.key, required this.cocktail, required this.user});

  final CocktailController controller = Get.find<CocktailController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                cocktail.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Obx(() {
                    return IconButton(
                      icon: Icon(
                        controller.isFavorite(cocktail.idDrink)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () =>
                          controller.toggleFavorite(cocktail.idDrink),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
