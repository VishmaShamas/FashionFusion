import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../liked_products_manager.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late bool _isLiked;
  final LikedProductsManager _manager = LikedProductsManager();

  @override
  void initState() {
    super.initState();
    _isLiked = _manager.isLiked(widget.product);
    _manager.addListener(_onLikedChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onLikedChanged);
    super.dispose();
  }

  void _onLikedChanged() {
    setState(() {
      _isLiked = _manager.isLiked(widget.product);
    });
  }

  void _toggleLike() {
    if (_isLiked) {
      _manager.unlikeProduct(widget.product);
    } else {
      _manager.likeProduct(widget.product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.product['discount_price'] != null && widget.product['discount_price'].toString().isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        backgroundColor: AppColors.blackColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.product['brand'] ?? '',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  widget.product['image'] ?? '',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.samiDarkColor,
                    child: const Icon(Icons.broken_image, color: Colors.white, size: 80),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.product['title'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Brand & Category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Text(
                    widget.product['brand'] ?? '',
                    style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: AppColors.lightAccentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.product['category'] ?? '',
                      style: TextStyle(color: AppColors.lightAccentColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  if (hasDiscount) ...[
                    Text(
                      'Rs. ${widget.product['price']}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Rs. ${widget.product['discount_price']}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Rs. ${widget.product['price']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.product['description'] ?? '',
                style: TextStyle(color: AppColors.greyColor, fontSize: 15),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.samiDarkColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Row(
  children: [
    Expanded( // 👈 This makes the button take up remaining space
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16), // Optional: consistent height
        ),
        onPressed: () {
          final url = widget.product['url'];
          if (url != null && url.toString().isNotEmpty) {
            // TODO: Implement url_launcher logic
          }
        },
        child: const Text(
          'Buy Now',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const SizedBox(width: 12), // 👈 Optional spacing between button and icon
    IconButton(
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_border,
        color: _isLiked ? Colors.red : Colors.white,
      ),
      onPressed: _toggleLike,
      tooltip: _isLiked ? 'Unlike' : 'Like',
    ),
  ],
),

        ),
      ),
    );
  }
}
