import 'package:app_netdrinks/controller/cocktail_list_controller.dart';
import 'package:app_netdrinks/controller/likes_controller.dart'; // Importe o LikesController
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/drink_likes.dart'; // Importe o DrinkLikes model
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CocktailCard extends StatelessWidget {
  final Cocktail cocktail;
  final String user;
  final double cardWidth = 300;
  final double cardHeight = 200;
  final LikesController likesController =
      Get.find<LikesController>(); // Inicialize o LikesController

  CocktailCard({super.key, required this.cocktail, required this.user});

  final CocktailListController controller = Get.find<CocktailListController>();

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
                  child: StreamBuilder<DrinkLikes>(
                    stream: likesController.getLikesStream(cocktail.idDrink),
                    builder: (context, snapshot) {
                      final likes = snapshot.data?.totalLikes ?? 0;

                      return Column(
                        children: [
                          Obx(() => IconButton(
                                icon: Icon(
                                  likesController.isLikedRx(cocktail.idDrink)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () => likesController
                                    .toggleLike(cocktail.idDrink),
                              )),
                          Text(
                            '$likes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
