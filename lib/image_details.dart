import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Displays the full-size version of an image.
class ImageDetails extends StatelessWidget {
  /// The image data containing the large image URL.
  final dynamic image;

  const ImageDetails({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: CachedNetworkImage(
            imageUrl: image['largeImageURL'],
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
