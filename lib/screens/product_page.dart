import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import 'product_detail.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  Set<String> _brands = {};
  Set<String> _categories = {};
  String _selectedBrand = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final String response = await rootBundle.loadString('../../assets/data/data.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _products = data;
      _filteredProducts = data;
      _brands = {'All', ...data.map((p) => p['brand'] as String? ?? '').where((b) => b.isNotEmpty)};
      _categories = {'All', ...data.map((p) => p['category'] as String? ?? '').where((c) => c.isNotEmpty)};
      _loading = false;
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesBrand = _selectedBrand == 'All' || product['brand'] == _selectedBrand;
        final matchesCategory = _selectedCategory == 'All' || product['category'] == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty ||
            (product['title']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (product['description']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        return matchesBrand && matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        backgroundColor: AppColors.blackColor,
        title: const Text('Shop Products', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Search products',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: AppColors.samiDarkColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterProducts();
                    },
                  ),
                  const SizedBox(height: 10),
                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          dropdownColor: AppColors.samiDarkColor,
                          value: _selectedBrand,
                          items: _brands
                              .map((brand) => DropdownMenuItem(
                                    value: brand,
                                    child: Text(
                                      brand,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBrand = value!;
                              _filterProducts();
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Brand',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: AppColors.samiDarkColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          dropdownColor: AppColors.samiDarkColor,
                          value: _selectedCategory,
                          items: _categories
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(
                                      cat,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                              _filterProducts();
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: AppColors.samiDarkColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Product Count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filteredProducts.length} products found',
                          style: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        if (_selectedBrand != 'All' || _selectedCategory != 'All' || _searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedBrand = 'All';
                                _selectedCategory = 'All';
                                _searchQuery = '';
                                _filterProducts();
                              });
                            },
                            child: const Text(
                              'Clear filters',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Product Grid
                  Expanded(
                    child: _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 50, color: Colors.white54),
                                const SizedBox(height: 10),
                                Text(
                                  'No products found',
                                  style: TextStyle(
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Try different filters or search terms',
                                  style: TextStyle(
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.65,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: AppColors.samiDarkColor,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(product: product),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image Container with fixed aspect ratio
                                      Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                          image: DecorationImage(
                                            image: NetworkImage(product['image'] ?? ''),
                                            fit: BoxFit.cover,
                                            onError: (exception, stackTrace) => const Icon(Icons.broken_image),
                                          ),
                                        ),
                                        child: product['image'] == null || product['image'].toString().isEmpty
                                            ? const Center(
                                                child: Icon(Icons.broken_image, size: 50, color: Colors.white54),
                                              )
                                            : null,
                                      ),
                                      // Product Details
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['title'] ?? 'No title',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.white,
                                                height: 1.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.store, size: 12, color: AppColors.greyColor),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    product['brand'] ?? 'No brand',
                                                    style: TextStyle(
                                                      color: AppColors.greyColor,
                                                      fontSize: 11,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.category, size: 12, color: AppColors.lightAccentColor),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    product['category'] ?? 'No category',
                                                    style: TextStyle(
                                                      color: AppColors.lightAccentColor,
                                                      fontSize: 11,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            // Price
                                            if (product['discount_price'] != null && product['discount_price'].toString().isNotEmpty)
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Rs. ${product['price']}',
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12,
                                                      decoration: TextDecoration.lineThrough,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Rs. ${product['discount_price']}',
                                                    style: TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              Text(
                                                'Rs. ${product['price']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}