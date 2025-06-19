import 'package:fashion_fusion/widgets/ui/loader.dart';
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
  try {
    final String response = await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> data = await json.decode(response) as List;
    
    if (data.isEmpty) {
      debugPrint('JSON data is empty');
      return;
    }

    setState(() {
      _products = List<Map<String, dynamic>>.from(data);
      _filteredProducts = _products;
      _brands = {'All'};
      _categories = {'All'};
      
      for (var product in _products) {
        if (product['brand'] != null) {
          _brands.add(product['brand'].toString());
        }
        if (product['category'] != null) {
          _categories.add(product['category'].toString());
        }
      }
      
      _loading = false;
    });
    
    debugPrint('Loaded ${_products.length} products');
    debugPrint('Brands: $_brands');
    debugPrint('Categories: $_categories');
  } catch (e) {
    debugPrint('Error loading products: $e');
    setState(() {
      _loading = false;
    });
  }
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
  if (_loading) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary),
    );
  }

  if (_products.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, 
            color: Colors.white54, size: 50),
          const SizedBox(height: 16),
          const Text('No products available',
            style: TextStyle(color: Colors.white)),
          TextButton(
            onPressed: _loadProducts,
            child: const Text('Retry',
              style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkScaffoldColor,
        title: const Text('Shop Products', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _loading
          ? const CustomLoadingAnimation()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: AppColors.samiDarkColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterProducts();
                    },
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  // Product Count & Clear
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredProducts.length} products found',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
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
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, color: Colors.white.withOpacity(0.3), size: 50),
                                const SizedBox(height: 12),
                                Text('No products found', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Try changing filters', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _filteredProducts.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.65,
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
      isExpanded: true,
      dropdownColor: AppColors.samiDarkColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: AppColors.samiDarkColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      style: const TextStyle(color: Colors.white),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
      items: items.map((e) => DropdownMenuItem(
        value: e,
        child: Text(e, 
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      )).toList(),
      onChanged: onChanged,
    );
  }

 Widget _buildProductCard(dynamic product) {
  // Ensure product is actually a Map
  if (product is! Map<String, dynamic>) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Invalid product', 
          style: TextStyle(color: Colors.white)),
      ),
    );
  }

  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
                color: Colors.black.withOpacity(0.1),
              ),
              child: product['image'] != null 
                  ? Image.network(
                      product['image'].toString(),
                      fit: BoxFit.scaleDown,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title']?.toString() ?? 'No Title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  product['brand']?.toString() ?? 'No Brand',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                _buildPriceWidget(product),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildImagePlaceholder() {
  return const Center(
    child: Icon(Icons.image_not_supported, 
      color: Colors.white24, size: 40),
  );
}

Widget _buildPriceWidget(Map<String, dynamic> product) {
  final price = product['price']?.toString() ?? 'N/A';
  final discountPrice = product['discount_price']?.toString();
  
  if (discountPrice != null) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Text(
          'Rs. $discountPrice',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),Text(
          'Rs. $price',
          style: const TextStyle(
            color: Colors.white54,
            decoration: TextDecoration.lineThrough,
            fontSize: 12,
          ),
        ),],
        )
      ],
    );
  }
  
  return Text(
    'Rs. $price',
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}}