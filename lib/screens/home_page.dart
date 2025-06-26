import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/screens/recommendation.dart';
import 'package:fashion_fusion/widgets/cards/product_card.dart';
import 'package:fashion_fusion/widgets/ui/loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _productFuture;
  final List<Map<String, String>> _trendingStyles = [
    {
      'title': 'Streetwear Essentials',
      'image': 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Minimalist Business',
      'image': 'https://images.unsplash.com/photo-1623880840102-7df0a9f3545b?q=80&w=464&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    },
    {
      'title': 'Athleisure Vibes',
      'image': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Urban Utility',
      'image': 'https://images.unsplash.com/photo-1551232864-3f0890e580d9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Retro Sportswear',
      'image': 'https://images.unsplash.com/photo-1617127368498-fb9c48e2d7db?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Korean Street Style',
      'image': 'https://images.unsplash.com/photo-1636471050641-08976fbbd83e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _productFuture = _loadProducts();
  }

  Future<List<Map<String, dynamic>>> _loadProducts() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('new_arrivals').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching new arrivals: $e');
    }
    return [];
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Hero Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.cardBackgroundColor,
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=800&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.darkScaffoldColor.withValues(alpha: 0.7),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Discover New Arrivals',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Personalized Recommendation Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalizedRecommendationPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.cardBackgroundColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personalized Recommendations',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'See outfits curated just for you',
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Trending Styles Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Trending Styles', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18, 
                        color: Colors.white
                      )),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All', 
                        style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _trendingStyles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final style = _trendingStyles[index];
                    return _TrendingStyleCard(style: style);
                  },
                ),
              ),
              const SizedBox(height: 24),
              // New Arrivals Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text('New Arrivals', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 18, 
                    color: Colors.white
                  )),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<dynamic>>(
                future: _productFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomLoadingAnimation(); // Replaced with your custom loader
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No products found', 
                        style: TextStyle(color: AppColors.textSecondaryColor)));
                  }
                  final products = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.63,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: products.take(10).length,
                    itemBuilder: (context, i) {
                      final product = products[i];
                      return ProductCard(product: product, parentContext: context);
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingStyleCard extends StatelessWidget {
  final Map<String, String> style;
  const _TrendingStyleCard({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(style['image']!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              style['title']!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

