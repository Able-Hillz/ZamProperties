import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zambia_real_estate/services/data_server_service.dart';

class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: DataSaverService.isDataSaverEnabled(),
      builder: (context, snapshot) {
        final isDataSaver = snapshot.data ?? false;
        final optimizedUrl = isDataSaver
            ? DataSaverService.getOptimizedImageUrl(imageUrl)
            : imageUrl;
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: CachedNetworkImage(
            imageUrl: optimizedUrl,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50),
            ),
            memCacheWidth: isDataSaver ? 800 : null,
            memCacheHeight: isDataSaver ? 600 : null,
          ),
        );
      },
    );
  }
}