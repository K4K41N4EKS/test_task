import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';

/// Service class that fetches images from the Pixabay API.
class ImageService {
  final Logger _logger = Logger('ImageService');
  final String _apiKey = '45944240-46e2c127f91f99d8b7c71169b'; 

  /// Fetches images from the Pixabay API based on the [query] and [page] number.
  /// Returns a list of images or throws an exception if an error occurs.
  Future<List<dynamic>> fetchImages(String query, int page) async {
    final String url =
        'https://pixabay.com/api/?key=$_apiKey&q=$query&image_type=photo&page=$page&per_page=20';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['hits'] as List<dynamic>;
      } else {
        _logger.severe('Failed to load images: ${response.statusCode}');
        throw Exception('Failed to load images');
      }
    } catch (error) {
      _logger.severe('Error occurred while fetching images: $error');
      throw Exception('Error occurred while fetching images');
    }
  }
}
