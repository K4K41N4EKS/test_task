import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'image_service.dart';
import 'image_details.dart';

/// Logger initialization for the ImageGallery class
final Logger _logger = Logger('ImageGalleryLogger');

/// The [ImageGallery] widget represents a gallery of images fetched from an API.
/// It supports searching for images and loading more images when scrolling.
class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key});

  @override
  ImageGalleryState createState() => ImageGalleryState();
}

/// The state class for [ImageGallery].
/// It handles the logic for image fetching, search, and pagination while managing
/// the user interface state.
class ImageGalleryState extends State<ImageGallery> {
  final ImageService _imageService = ImageService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<dynamic> _images = [];
  String _query = 'nature';
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Handles scrolling events and triggers image fetching when the user scrolls
  /// to the bottom of the gallery.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent && _hasMore) {
      _fetchImages();
    }
  }

  /// Handles changes in the search input field. It debounces user input to avoid
  /// frequent API calls and updates the gallery based on the new search query.
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _images.clear();
        _page = 1;
        _hasMore = true;
        _query = _searchController.text.isNotEmpty
            ? _searchController.text
            : 'nature';
        _fetchImages();
      });
    });
  }

  /// Fetches images from the API based on the current search query and page number.
  /// It handles errors and ensures that the loading state is updated accordingly.
  Future<void> _fetchImages() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newImages = await _imageService
          .fetchImages(_query, _page)
          .timeout(const Duration(seconds: 10));

      if (newImages.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          _page++;
          _images.addAll(newImages);
        });
      }
    } catch (error) {
      _logger.severe('Error loading images: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Intl.message(
                'Error loading images. Please try again later.',
                name: 'errorLoadingImages',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Determines the number of columns based on the screen width
  int _calculateCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 4; 
    } else if (width >= 800) {
      return 3; 
    } else {
      return 2; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: (value) => _onSearchChanged(),
          decoration: InputDecoration(
            hintText: Intl.message('Search images...', name: 'searchHint'),
            border: InputBorder.none,
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  /// Builds the main body of the gallery. It shows either a grid of images or a
  /// message if no images are found.
  Widget _buildBody(BuildContext context) {
    if (_images.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          Intl.message('No images found.', name: 'noImagesFound'),
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _calculateCrossAxisCount(context),
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.0, // Квадратная сетка
      ),
      itemCount: _images.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _images.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final image = _images[index];
        return _buildImageCard(image);
      },
    );
  }

  /// Builds an image card widget that displays the image, number of likes, and
  /// views. Clicking on the card opens the image details.
  Widget _buildImageCard(dynamic image) {
    return GestureDetector(
      onTap: () => _openImageDetails(image),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: image['webformatURL'],
                fit: BoxFit.contain, 
                width: double.infinity,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${image['likes']}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${image['views']}'),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Opens the image details page with a fade transition animation.
  void _openImageDetails(dynamic image) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ImageDetails(image: image),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
