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
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        title: const Text('Liked Products'),
        backgroundColor: AppColors.blackColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: likedProducts.isEmpty
          ? Center(
              child: Text(
                'No liked products yet.',
                style: TextStyle(color: AppColors.greyColor, fontSize: 18),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: likedProducts.length,
              itemBuilder: (context, index) {
                final product = likedProducts[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.samiDarkColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            product['image'] ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.samiDarkColor,
                              child: const Icon(Icons.broken_image, color: Colors.white, size: 60),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Text(
                          product['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Rs. ${product['discount_price']?.toString().isNotEmpty == true ? product['discount_price'] : product['price']}',
                          style: TextStyle(
                            color: product['discount_price']?.toString().isNotEmpty == true
                                ? AppColors.primary
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          tooltip: 'Unlike',
                          onPressed: () => _manager.unlikeProduct(product),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
