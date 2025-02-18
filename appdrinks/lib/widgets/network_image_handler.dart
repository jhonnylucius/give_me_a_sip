import 'package:app_netdrinks/widgets/cocktail_fill_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageHandler extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NetworkImageHandler({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    required Container Function(dynamic context, dynamic url) placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: CocktailFillLoading(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[900],
          height: height,
          width: width,
          child: const Center(
            child: Icon(
              Icons.local_bar_rounded,
              color: Colors.redAccent,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
