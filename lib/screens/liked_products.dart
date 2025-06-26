import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/widgets/cards/product_card.dart';

class LikedProducts extends StatefulWidget {
  const LikedProducts({super.key});

  @override
  State<LikedProducts> createState() => _LikedProductsState();
}

class _LikedProductsState extends State<LikedProducts> {
  late Future<List<Map<String, dynamic>>> _likedProductsFuture;

  @override
  void initState() {
    super.initState();
    _likedProductsFuture = _fetchLikedProducts();
  }

  Future<List<Map<String, dynamic>>> _fetchLikedProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .collection('likedProducts')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _unlikeProduct(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .collection('likedProducts')
        .doc(productId)
        .delete();

    // Refresh the list
    setState(() {
      _likedProductsFuture = _fetchLikedProducts();
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from favorites')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      appBar: AppBar(
        title: const Text('Your Favorites', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.darkScaffoldColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _likedProductsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ignore: deprecated_member_use
                  Icon(Icons.favorite_border, size: 60, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No favorites yet',
                      // ignore: deprecated_member_use
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Like products to see them here',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
                ],
              ),
            );
          }

          final likedProducts = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: likedProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.64,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final product = likedProducts[index];
                return Stack(
                  children: [
                    ProductCard(
                      product: product,
                      parentContext: context,
                    ),
                    // Heart Button Positioned
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          final productId = product['id']?.toString();
                          if (productId != null) {
                            _unlikeProduct(productId);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
