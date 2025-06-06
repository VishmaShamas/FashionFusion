import 'package:flutter/material.dart';

class LikedProductsManager extends ChangeNotifier {
  static final LikedProductsManager _instance = LikedProductsManager._internal();
  factory LikedProductsManager() => _instance;
  LikedProductsManager._internal();

  final List<Map<String, dynamic>> _likedProducts = [];

  List<Map<String, dynamic>> get likedProducts => List.unmodifiable(_likedProducts);

  bool isLiked(Map<String, dynamic> product) {
    return _likedProducts.any((p) => p['id'] == product['id']);
  }

  void likeProduct(Map<String, dynamic> product) {
    if (!isLiked(product)) {
      _likedProducts.add(product);
      notifyListeners();
    }
  }

  void unlikeProduct(Map<String, dynamic> product) {
    _likedProducts.removeWhere((p) => p['id'] == product['id']);
    notifyListeners();
  }
}
