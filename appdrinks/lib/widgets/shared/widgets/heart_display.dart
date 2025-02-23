import 'package:flutter/material.dart';

import '../../../contants/ranking_contants.dart';

class HeartDisplay extends StatelessWidget {
  final int likes;
  final double percentage;
  final double size;
  final Color color;

  const HeartDisplay({
    super.key,
    required this.likes,
    required this.percentage,
    this.size = RankingConstants.heartIconSize,
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.favorite,
          size: size,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: size * 0.75,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
