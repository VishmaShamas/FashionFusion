import 'package:flutter/material.dart';

class PersonalizedRecommendationPage extends StatefulWidget {
  const PersonalizedRecommendationPage({super.key});

  @override
  State<PersonalizedRecommendationPage> createState() =>
      _PersonalizedRecommendationPageState();
}

class _PersonalizedRecommendationPageState
    extends State<PersonalizedRecommendationPage> {
  // Dummy outfits data
  final List<String> _outfitImages = [
    'https://via.placeholder.com/300x400.png?text=Outfit+1',
    'https://via.placeholder.com/300x400.png?text=Outfit+2',
    'https://via.placeholder.com/300x400.png?text=Outfit+3',
    'https://via.placeholder.com/300x400.png?text=Outfit+4',
    'https://via.placeholder.com/300x400.png?text=Outfit+5',
    'https://via.placeholder.com/300x400.png?text=Outfit+6',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Personalized Recommendation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Search Bar with camera icon on the right
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type here',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: () {
                        // Open camera or image picker for style-based search
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Grid of recommended outfits
              GridView.builder(
                itemCount: _outfitImages.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // Adjust aspect ratio for your images
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return _buildOutfitCard(_outfitImages[index]);
                },
              ),

              const SizedBox(height: 12),

              // More button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Load more outfits, show more details, or navigate
                  },
                  child: const Text(
                    'More',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      // Optional bottom navigation bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildOutfitCard(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        // Navigate to other pages if needed
      },
      selectedItemColor: Colors.purple.shade700,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.star_border),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
