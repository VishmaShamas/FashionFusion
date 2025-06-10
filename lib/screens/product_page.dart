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
    final String response = await rootBundle.loadString('data/data.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _products = data;
      _filteredProducts = data;
      _brands = {'All', ...data.map((p) => p['brand'] ?? '').where((b) => b.isNotEmpty)};
      _categories = {'All', ...data.map((p) => p['category'] ?? '').where((c) => c.isNotEmpty)};
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
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: AppColors.samiDarkColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterProducts();
                    },
                  ),
                  const SizedBox(height: 14),
                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Brand',
                          value: _selectedBrand,
                          items: _brands,
                          onChanged: (val) {
                            _selectedBrand = val!;
                            _filterProducts();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Category',
                          value: _selectedCategory,
                          items: _categories,
                          onChanged: (val) {
                            _selectedCategory = val!;
                            _filterProducts();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Product Count & Clear
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredProducts.length} products found',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      if (_selectedBrand != 'All' || _selectedCategory != 'All' || _searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _selectedBrand = 'All';
                            _selectedCategory = 'All';
                            _searchQuery = '';
                            _filterProducts();
                          },
                          child: const Text('Clear Filters', style: TextStyle(color: AppColors.primary)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Product Grid
                  Expanded(
                    child: _filteredProducts.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, color: Colors.white38, size: 50),
                                SizedBox(height: 8),
                                Text('No products found', style: TextStyle(color: Colors.white54, fontSize: 15)),
                                Text('Try changing filters', style: TextStyle(color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            itemCount: _filteredProducts.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.68,
                            ),
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return _buildProductCard(product);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required Set<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.samiDarkColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: AppColors.samiDarkColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      style: const TextStyle(color: Colors.white),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Card(
      color: AppColors.samiDarkColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                product['image'] ?? '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40, color: Colors.white54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(product['brand'] ?? '', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(product['category'] ?? '', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 8),
                  if (product['discount_price'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rs. ${product['price']}', style: const TextStyle(color: Colors.red, decoration: TextDecoration.lineThrough, fontSize: 12)),
                        Text('Rs. ${product['discount_price']}', style: const TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    )
                  else
                    Text('Rs. ${product['price']}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
