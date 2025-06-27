import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_fusion/widgets/ui/loader.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/cards/product_card.dart';
import 'package:flutter/services.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = []; // All filtered products
  List<dynamic> _paginatedProducts = []; // Products for current page
  Set<String> _brands = {};
  Set<String> _categories = {};
  String _selectedBrand = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _loading = true;
  bool _showFilters = true;
  final ScrollController _scrollController = ScrollController();
   // Pagination state
  int _limit = 30;
  // int _currentPage = 0;
  int _totalPages = 1;



  DocumentSnapshot? _lastDoc;
bool _hasMore = true;
bool _isLoadingMore = false;
int _currentPage = 0;

List<DocumentSnapshot> _lastDocs = []; // For going back to prev page

//   Future<void> _loadProducts({bool isLoadMore = false, bool isPrev = false}) async {
//   if (_isLoadingMore) return;
//   setState(() {
//     _loading = true;
//     _isLoadingMore = true;
//   });

//   try {
//     Query query = FirebaseFirestore.instance
//         .collection('products')
//         .orderBy('title') // Make sure "title" is indexed!
//         .limit(_limit);

//     if (isLoadMore && _lastDoc != null) {
//       query = query.startAfterDocument(_lastDoc!);
//     }
//     // For prev: you’d need to keep previous docs. Not needed if you only allow forward.

//     final snap = await query.get();
//     final docs = snap.docs;

//     setState(() {
//       _allProducts = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//       _paginatedProducts = _allProducts;
//       _filteredProducts = _allProducts;
//       _brands = {'All', ..._allProducts.map((p) => p['brand'] ?? '').where((b) => b.toString().isNotEmpty)};
//       _categories = {'All', ..._allProducts.map((p) => p['category'] ?? '').where((c) => c.toString().isNotEmpty)};
//       _loading = false;
//       _isLoadingMore = false;

//       if (docs.length < _limit) {
//         _hasMore = false;
//       } else {
//         _hasMore = true;
//       }

//       if (docs.isNotEmpty) {
//         _lastDoc = docs.last;
//         if (isLoadMore) {
//           _lastDocs.add(_lastDoc!);
//         }
//       }
//     });
//   } catch (e) {
//     setState(() {
//       _loading = false;
//       _isLoadingMore = false;
//     });
//   }
// }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final String response = await rootBundle.loadString('assets/data/data2.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _allProducts = data;
        _brands = {'All', ..._allProducts.map((p) => p['brand'] ?? '').where((b) => b.toString().isNotEmpty)};
        _categories = {'All', ..._allProducts.map((p) => p['category'] ?? '').where((c) => c.toString().isNotEmpty)};
        _applyFilters(); // Initial filter
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _allProducts = [];
        _filteredProducts = [];
        _paginatedProducts = [];
      });
    }
  }

  Set<String> get filteredBrands {
  if (_selectedCategory == 'All') {
    return _brands;
  }
  final filtered = _allProducts
      .where((p) => p['category'] == _selectedCategory)
      .map((p) => p['brand'] ?? '')
      .where((b) => b.toString().isNotEmpty)
      .toSet();
  return {'All', ...filtered};
}

Set<String> get filteredCategories {
  if (_selectedBrand == 'All') {
    return _categories;
  }
  final filtered = _allProducts
      .where((p) => p['brand'] == _selectedBrand)
      .map((p) => p['category'] ?? '')
      .where((c) => c.toString().isNotEmpty)
      .toSet();
  return {'All', ...filtered};
}

  void _applyFilters() {
    // Filter all products based on current filters
    _filteredProducts = _allProducts.where((product) {
      final matchesBrand = _selectedBrand == 'All' || product['brand'] == _selectedBrand;
      final matchesCategory = _selectedCategory == 'All' || product['category'] == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          (product['title']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (product['description']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesBrand && matchesCategory && matchesSearch;
    }).toList();

    // Update pagination
    _totalPages = (_filteredProducts.length / _limit).ceil();
    if (_currentPage >= _totalPages && _totalPages > 0) {
      _currentPage = _totalPages - 1;
    } else if (_totalPages == 0) {
      _currentPage = 0;
    }
    
    // Update paginated products
    _updatePaginatedProducts();
  }

  void _updatePaginatedProducts() {
    final start = _currentPage * _limit;
    final end = (_currentPage + 1) * _limit;
    _paginatedProducts = _filteredProducts.sublist(
      start,
      end > _filteredProducts.length ? _filteredProducts.length : end,
    );
    
    // Scroll to top when page changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _changePage(int page) {
    if (page < 0 || page >= _totalPages) return;
    setState(() {
      _currentPage = page;
      _updatePaginatedProducts();
    });
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _currentPage > 0 ? () => _changePage(_currentPage - 1) : null,
          ),
          
          // Calculate the range of pages to show (3 at a time)
          for (int i = _currentPage - 1; i <= _currentPage + 1; i++)
            if (i >= 0 && i < _totalPages)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => _changePage(i),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == _currentPage ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: i == _currentPage ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          
          // Next button
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _currentPage < _totalPages - 1 ? () => _changePage(_currentPage + 1) : null,
          ),
        ],
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
      items: items
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CustomLoadingAnimation());
    }

    if (_allProducts.isEmpty) {
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
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            if (_showFilters) ...[
              Padding(
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
                        setState(() {
                          _searchQuery = value;
                          _applyFilters();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Filters
                    Row(
                      children: [
                        Expanded(
  child: _buildDropdown(
    label: 'Brand',
    value: filteredBrands.contains(_selectedBrand) ? _selectedBrand : 'All',
    items: filteredBrands,
    onChanged: (val) {
      setState(() {
        _selectedBrand = val!;
        // If the current selected category doesn't exist for the selected brand, reset to All
        if (!filteredCategories.contains(_selectedCategory)) {
          _selectedCategory = 'All';
        }
        _applyFilters();
      });
    },
  ),
),

                        const SizedBox(width: 12),
                        Expanded(
  child: _buildDropdown(
    label: 'Category',
    value: filteredCategories.contains(_selectedCategory) ? _selectedCategory : 'All',
    items: filteredCategories,
    onChanged: (val) {
      setState(() {
        _selectedCategory = val!;
        // If the current selected brand doesn't exist for the selected category, reset to All
        if (!filteredBrands.contains(_selectedBrand)) {
          _selectedBrand = 'All';
        }
        _applyFilters();
      });
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
                              setState(() {
                                _selectedBrand = 'All';
                                _selectedCategory = 'All';
                                _searchQuery = '';
                                _applyFilters();
                              });
                            },
                            child: const Text(
                              'Clear Filters',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
            ],
            if (_filteredProducts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        color: Colors.white.withOpacity(0.3),
                        size: 50,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No products found',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try changing filters',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _paginatedProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (context, index) {
                      final product = _paginatedProducts[index];
                      return ProductCard(
                        product: product,
                        parentContext: context,
                      );
                    },
                  ),
                  if (_totalPages > 1) _buildPagination(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}