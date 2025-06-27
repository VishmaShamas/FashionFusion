import 'package:flutter/material.dart';
import '../constants/colors.dart';

class WardrobeRecommendationPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const WardrobeRecommendationPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkScaffoldColor,
        title: const Text(
          'Wardrobe Recommendation',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style, color: Colors.white54, size: 60),
                  const SizedBox(height: 12),
                  const Text(
                    'No recommended items',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'http://192.168.18.73:8000${item['imageUrl']}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white54,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white38),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
