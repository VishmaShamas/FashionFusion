import 'package:flutter/material.dart';
import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/screens/product_detail.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic>? product;
  final BuildContext parentContext;

  const ProductCard({
    super.key,
    required this.product,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    if (product == null || product is! Map<String, dynamic>) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Invalid product',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        parentContext,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product!),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  color: Colors.black.withValues(alpha: 0.1),
                ),
                child: product!['image'] != null
                    ? Image.network(
                        product!['image'].toString(),
                        fit: BoxFit.scaleDown,
                        errorBuilder: (_, __, ___) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product!['title']?.toString() ?? 'No Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    product!['brand']?.toString() ?? 'No Brand',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  _buildPriceWidget(product!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
  return const Center(
    child: Icon(Icons.image_not_supported, 
      color: Colors.white24, size: 40),
  );
}

Widget _buildPriceWidget(Map<String, dynamic> product) {
  final price = product['price']?.toString() ?? 'N/A';
  final discountPrice = product['discount_price']?.toString();
  
  if (discountPrice != null && discountPrice != 'null' && discountPrice != '0' && discountPrice != 'Null') {
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
