import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/models/drink_likes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class LikeCounter extends GetWidget<LikesController> {
  final String drinkId;

  const LikeCounter({
    required this.drinkId,
    super.key,
    required TextStyle textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DrinkLikes>(
      stream: controller.getLikesStream(drinkId),
      builder: (context, likesSnapshot) {
        return FutureBuilder<bool>(
          future: Future.value(controller.isLikedRx(drinkId)),
          builder: (context, likedSnapshot) {
            final likes = likesSnapshot.data?.totalLikes ?? 0;
            final isLiked = likedSnapshot.data ?? false;

            return Column(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () => controller.toggleLike(drinkId),
                ),
                Text(
                  '$likes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
