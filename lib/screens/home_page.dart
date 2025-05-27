import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dummy popular items
  final List<Map<String, dynamic>> _popularItems = [
    {
      'brand': 'Zara',
      'imageUrl': 'https://via.placeholder.com/400x400.png?text=Zara+Jacket',
      'price': 39.99,
    },
    {
      'brand': 'Nike',
      'imageUrl': 'https://via.placeholder.com/400x400.png?text=Nike+Shoes',
      'price': 59.99,
    },
    {
      'brand': 'Levi\'s',
      'imageUrl': 'https://via.placeholder.com/400x400.png?text=Levi%27s+Jeans',
      'price': 49.99,
    },
    {
      'brand': 'H&M',
      'imageUrl': 'https://via.placeholder.com/400x400.png?text=H%26M+Jacket',
      'price': 29.99,
    },
    {
      'brand': 'Adidas',
      'imageUrl': 'https://via.placeholder.com/400x400.png?text=Adidas+Shoes',
      'price': 64.99,
    },
    {
      'brand': 'GUCCI',
      'imageUrl': 'https://via.placeholder.com/400x400.png?text=GUCCI+Bag',
      'price': 199.99,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top-level scroll view
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Logo, Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Branding
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'FASHION\nFUSION',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),

                  // Profile Picture & Name
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'Lorem Ipsum',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Lorem Ipsum',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Placeholder user photo
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage(
                          'assets/profile.jpg',
                        ), // or a placeholder
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search bar
              const Text(
                'Search here',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Type here',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Categories (Jacket, Shoes, Jeans, Filter)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('Jacket', true),
                    _buildCategoryChip('Shoes', false),
                    _buildCategoryChip('Jeans', false),
                    _buildFilterChip(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Horizontal Banner (Get Personalized Fashion)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/hanger.jpg'), // or network image
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black45,
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Text(
                          'Get Personalized Fashion',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // Navigate or show a new screen for personalized fashion
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Popular
              const Text(
                'Popular',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Grid of popular items (Dummy Data)
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _popularItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final item = _popularItems[index];
                  return _buildPopularItem(
                    item['imageUrl'],
                    item['price'],
                    item['brand'],
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Build category chips
  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
        selectedColor: Colors.purple.shade700,
        backgroundColor: Colors.white,
        onSelected: (selected) {
          // Handle category selection logic
        },
      ),
    );
  }

  // Build filter chip
  Widget _buildFilterChip() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          // Show filter options or new page
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.filter_list),
        ),
      ),
    );
  }

  // Build a popular item card
  Widget _buildPopularItem(String imageUrl, double price, String brand) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail page
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child:
                  imageUrl.isNotEmpty
                      ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                      : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(brand, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0, // Adjust as needed
      onTap: (index) {
        // Handle navigation logic
      },
      showUnselectedLabels: false,
      selectedItemColor: Colors.purple.shade700,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
