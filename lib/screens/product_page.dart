import 'package:fashion_fusion/widgets/ui/loader.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/cards/product_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
  int _limit = 30;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({bool isLoadMore = false}) async {
    if (_isLoadingMore || (!_hasMore && isLoadMore)) return;

    try {
      setState(() {
        if (isLoadMore)
          _isLoadingMore = true;
        else
          _loading = true;
      });

      Query query = FirebaseFirestore.instance
          .collection('products')
          .orderBy('title') // ✅ Ensure "title" is indexed
          .limit(_limit);

      if (_lastDoc != null && isLoadMore) {
        query = query.startAfterDocument(_lastDoc!);
      }

      final snap = await query.get();
      final docs = snap.docs;

      final data =
          docs.map((doc) {
            final docData = doc.data() as Map<String, dynamic>? ?? {};
            return {'id': doc.id, ...docData};
          }).toList();

      setState(() {
        if (isLoadMore) {
          _products.addAll(data);
          _filteredProducts.addAll(data);
        } else {
          _products = data;
          _filteredProducts = data;
          _brands = {'All', ..._products.map((p) => p['brand'].toString())};
          _categories = {
            'All',
            ..._products.map((p) => p['category'].toString()),
          };
        }

        if (docs.length < _limit) _hasMore = false;
        if (docs.isNotEmpty) _lastDoc = docs.last;
        _loading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
      setState(() {
        _loading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts =
          _products.where((product) {
            final matchesBrand =
                _selectedBrand == 'All' || product['brand'] == _selectedBrand;
            final matchesCategory =
                _selectedCategory == 'All' ||
                product['category'] == _selectedCategory;
            final matchesSearch =
                _searchQuery.isEmpty ||
                (product['title']?.toString().toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (product['description']?.toString().toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false);
            return matchesBrand && matchesCategory && matchesSearch;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CustomLoadingAnimation());
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 50),
            const SizedBox(height: 16),
            const Text(
              'No products available',
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: _loadProducts,
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkScaffoldColor,
        title: const Text(
          'Shop Products',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body:
          _loading
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
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        filled: true,
                        fillColor: AppColors.samiDarkColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 16,
                        ),
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
                          // ignore: deprecated_member_use
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        if (_selectedBrand != 'All' ||
                            _selectedCategory != 'All' ||
                            _searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _selectedBrand = 'All';
                              _selectedCategory = 'All';
                              _searchQuery = '';
                              _filterProducts();
                            },
                            child: const Text(
                              'Clear Filters',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Product Grid
                    Expanded(
                      child:
                          _filteredProducts.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // ignore: deprecated_member_use
                                    Icon(
                                      Icons.search_off,
                                      color: Colors.white.withOpacity(0.3),
                                      size: 50,
                                    ),
                                    const SizedBox(height: 12),
                                    // ignore: deprecated_member_use
                                    Text(
                                      'No products found',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // ignore: deprecated_member_use
                                    Text(
                                      'Try changing filters',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Expanded(
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (
                                    ScrollNotification scrollInfo,
                                  ) {
                                    if (!_isLoadingMore &&
                                        scrollInfo.metrics.pixels >=
                                            scrollInfo.metrics.maxScrollExtent -
                                                200 &&
                                        _hasMore) {
                                      _loadProducts(isLoadMore: true);
                                    }
                                    return false;
                                  },
                                  child: GridView.builder(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    itemCount: _filteredProducts.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                          childAspectRatio: 0.62,
                                        ),
                                    itemBuilder: (context, index) {
                                      final product = _filteredProducts[index];
                                      return ProductCard(
                                        product: product,
                                        parentContext: context,
                                      );
                                    },
                                  ),
                                ),
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
      items:
          items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }
}
