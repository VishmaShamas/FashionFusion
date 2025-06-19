import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../liked_products_manager.dart';

class LikedProducts extends StatefulWidget {
  const LikedProducts({super.key});

  @override
  State<LikedProducts> createState() => _LikedProductsState();
}

class _LikedProductsState extends State<LikedProducts> {
  final LikedProductsManager _manager = LikedProductsManager();

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onLikedChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onLikedChanged);
    super.dispose();
  }

  void _onLikedChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final likedProducts = _manager.likedProducts;
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      appBar: AppBar(
        title: const Text(
          'Your Favorites',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.darkScaffoldColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: likedProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 60,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Like products to see them here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.69,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: likedProducts.length,
                itemBuilder: (context, index) {
                  final product = likedProducts[index];
                  return _buildLikedProductCard(product);
                },
              ),
            ),
    );
  }

  Widget _buildLikedProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.samiDarkColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: product['image']?.toString().isNotEmpty == true
                      ? Image.network(
                          product['image'],
                          fit: BoxFit.scaleDown,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              // Product Details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title']?.toString() ?? 'No Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildPriceWidget(product),
                  ],
                ),
              ),
            ],
          ),
          // Like Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _manager.unlikeProduct(product),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.black.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.white24,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildPriceWidget(Map<String, dynamic> product) {
  final price = product['price']?.toString() ?? 'N/A';
  final discountPrice = product['discount_price']?.toString();
  
  if (discountPrice != null) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Text(
          'Rs. $discountPrice',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),Text(
          'Rs. $price',
          style: const TextStyle(
            color: Colors.white54,
            decoration: TextDecoration.lineThrough,
            fontSize: 12,
          ),
        ),],
        )
      ],
    );
  }
  
  return Text(
    'Rs. $price',
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}}