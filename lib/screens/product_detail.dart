import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Product Data
    final String productImage =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSu455LECEzVD_8MPTH_2ECl2sxGFPGfw4gag&s';
    final String brandLogo =
        'data:image/jpeg;base64,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'; // E.g., Pull & Bear
    final String brandName = 'Zara';
    final String brandHandle = '@pull&bearofficial';
    final String productTitle = 'Pull & Bear Men’s Fall Urban Collection';
    final double price = 26.15;
    final double rating = 4.8;
    final String description =
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text since the 1500s.';

    return Scaffold(
      // (Optional) If you want to customize the background color
      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top product image with a menu icon
              Stack(
                children: [
                  // Large product image with rounded corners
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.network(
                      productImage,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Positioned menu icon at top right
                  Positioned(
                    top: 16,
                    right: 16,
                    child: InkWell(
                      onTap: () {
                        // Handle more menu (favorite, share, etc.)
                      },
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              // Product Card with brand, price, etc.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Info Row (logo, brand name, handle, heart icon)
                      Row(
                        children: [
                          // Brand Logo
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(brandLogo),
                          ),
                          const SizedBox(width: 12),
                          // Brand Text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brandName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                brandHandle,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Favorite Icon
                          InkWell(
                            onTap: () {
                              // Toggle favorite logic
                            },
                            child: const Icon(Icons.favorite_border),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Product Title & Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              productTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Star Rating
                      Row(
                        children: [
                          // Generate star icons based on rating
                          ...List.generate(5, (index) {
                            double starIndex = index + 1;
                            return Icon(
                              starIndex <= rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '$rating',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Product Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),

              const SizedBox(height: 24),

              // CTA Button (Get More Info)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Implementation for more info
                    },
                    child: const Text(
                      'Get  More info',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // Example bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Navigation logic (e.g., go to home, wishlist, profile)
        },
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
      ),
    );
  }
}
