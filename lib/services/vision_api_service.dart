import 'dart:convert';
import 'dart:io';
import 'package:googleapis/vision/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

class VisionApiService {
  static const _scopes = [VisionApi.cloudVisionScope];
  final ServiceAccountCredentials _credentials;

  VisionApiService._(this._credentials);

  static Future<VisionApiService> create(String jsonKeyPath) async {
    final jsonString = await File(jsonKeyPath).readAsString();
    final credentials = ServiceAccountCredentials.fromJson(jsonString);
    return VisionApiService._(credentials);
  }

  Future<List<String>> analyzeImage(File image) async {
    final client = await clientViaServiceAccount(_credentials, _scopes);
    final vision = VisionApi(client);

    try {
      // Read image bytes
      final imageBytes = await image.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Create the request
      final request =
          AnnotateImageRequest()
            ..image = Image()
            ..image?.content = base64Image
            ..features = [
              Feature()
                ..type = 'LABEL_DETECTION'
                ..maxResults = 10,
              Feature()
                ..type = 'OBJECT_LOCALIZATION'
                ..maxResults = 10,
            ];

      final batchRequest = BatchAnnotateImagesRequest()..requests = [request];

      // Call the API
      final response = await vision.images.annotate(batchRequest);
      final annotations = response.responses?.first;

      // Process the results
      final labels = <String>[];

      // Add label annotations
      annotations?.labelAnnotations?.forEach((annotation) {
        if (annotation.description != null) {
          labels.add(annotation.description!);
        }
      });

      // Add object annotations
      annotations?.localizedObjectAnnotations?.forEach((annotation) {
        if (annotation.name != null) {
          labels.add(annotation.name!);
        }
      });

      return labels;
    } finally {
      client.close();
    }
  }

  Future<String?> categorizeClothingItem(File image) async {
    final labels = await analyzeImage(image);

    // Define clothing categories and their related keywords
    const categoryKeywords = {
      'Shirts': ['shirt', 't-shirt', 'blouse', 'top', 'tank top', 'polo'],
      'Jeans': ['jeans', 'denim', 'pants', 'trousers'],
      'Shoes': ['shoe', 'sneaker', 'boot', 'footwear', 'sandals'],
      'Jackets': ['jacket', 'coat', 'hoodie', 'sweatshirt', 'cardigan'],
      'Accessories': ['hat', 'cap', 'scarf', 'gloves', 'belt', 'sunglasses'],
    };

    // Find the best matching category
    for (final label in labels) {
      final lowerLabel = label.toLowerCase();
      for (final entry in categoryKeywords.entries) {
        if (entry.value.any((keyword) => lowerLabel.contains(keyword))) {
          return entry.key;
        }
      }
    }

    return 'Others'; // Default category if no match found
  }
}
