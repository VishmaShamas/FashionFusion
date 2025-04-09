import 'package:flutter/material.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  // Dummy outfits/clothes data
  final List<Map<String, dynamic>> _wardrobeItems = [
    {
      'imageUrl': 'https://via.placeholder.com/300x300.png?text=Outfit+1',
      'style': 'Casual',
    },
    {
      'imageUrl': 'https://via.placeholder.com/300x300.png?text=Outfit+2',
      'style': 'Casual',
    },
    {
      'imageUrl': 'https://via.placeholder.com/300x300.png?text=Outfit+3',
      'style': 'Casual',
    },
    {
      'imageUrl': 'https://via.placeholder.com/300x300.png?text=Outfit+4',
      'style': 'Casual',
    },
    // Add more items as needed
  ];

  // Example categories
  final List<String> _categories = ['All', 'Shoes', 'Jeans', 'Shirts'];
  String _selectedCategory = 'All';

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
                'Wardrobe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Search bar & filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type here',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (val) {
                          // Implement search logic if needed
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      // Show filter or advanced options
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_list),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Category chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      _categories.map((cat) {
                        bool isSelected = (cat == _selectedCategory);
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: Colors.purple.shade700,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = cat);
                                // Filter logic if needed
                              }
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Add clothes button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to add clothes screen or open image picker
                  },
                  child: const Text(
                    'Add clothes +',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Wardrobe grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _wardrobeItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final item = _wardrobeItems[index];
                  return _buildWardrobeCard(item['imageUrl'], item['style']);
                },
              ),
            ],
          ),
        ),
      ),
      // Bottom nav bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWardrobeCard(String imageUrl, String style) {
    return GestureDetector(
      onTap: () {
        // Navigate to clothing item details
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Outfit image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            // Style label
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                style,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        // Implement navigation logic
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
