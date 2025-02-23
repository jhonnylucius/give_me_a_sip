import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageHandler extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const NetworkImageHandler({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.height = 200,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageUrl.startsWith('assets/')
          ? Image.asset(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width,
                  height: height,
                  color: Colors.grey[300],
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            )
          : CachedNetworkImage(
              imageUrl: imageUrl,
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, url) => Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: Icon(Icons.error, color: Colors.red),
              ),
            ),
    );
  }
}
