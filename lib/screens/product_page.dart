import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../constants/colors.dart';
import '../widgets/ui/loader.dart';
import '../widgets/cards/product_card.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];
  List<dynamic> _paginatedProducts = [];
  Set<String> _brands = {};
  Set<String> _categories = {};

  String _selectedBrand = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _loading = true;
  bool _showFilters = true;
  final ScrollController _scrollController = ScrollController();

  // Pagination
  int _limit = 30;
  int _currentPage = 0;
  int _totalPages = 1;

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
      final String response = await rootBundle.loadString(
        'assets/data/data2.json',
      );
      final List<dynamic> data = json.decode(response);
      setState(() {
        _allProducts = data;
        // build the full sets
        _brands = {
          'All',
          ..._allProducts
              .map((p) => p['brand']?.toString() ?? '')
              .where((b) => b.isNotEmpty),
        };
        _categories = {
          'All',
          ..._allProducts
              .map((p) => p['category']?.toString() ?? '')
              .where((c) => c.isNotEmpty),
        };
        _applyFilters();
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

  void _applyFilters() {
    // filter products list
    _filteredProducts =
        _allProducts.where((product) {
          final matchesBrand =
              _selectedBrand == 'All' || product['brand'] == _selectedBrand;
          final matchesCategory =
              _selectedCategory == 'All' ||
              product['category'] == _selectedCategory;
          final matchesSearch =
              _searchQuery.isEmpty ||
              product['title']?.toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ==
                  true ||
              product['description']?.toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ==
                  true;
          return matchesBrand && matchesCategory && matchesSearch;
        }).toList();

    // pagination math
    _totalPages = (_filteredProducts.length / _limit).ceil();
    if (_totalPages == 0) {
      _currentPage = 0;
    } else if (_currentPage >= _totalPages) {
      _currentPage = _totalPages - 1;
    }
    _updatePaginatedProducts();
  }

  void _updatePaginatedProducts() {
    final start = _currentPage * _limit;
    final end = start + _limit;
    _paginatedProducts = _filteredProducts.sublist(
      start,
      end > _filteredProducts.length ? _filteredProducts.length : end,
    );
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
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed:
                _currentPage > 0 ? () => _changePage(_currentPage - 1) : null,
          ),
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
                      color:
                          i == _currentPage
                              ? AppColors.primary
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color:
                            i == _currentPage ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed:
                _currentPage < _totalPages - 1
                    ? () => _changePage(_currentPage + 1)
                    : null,
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
      value: items.contains(value) ? value : 'All',
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
                  child: Text(e, overflow: TextOverflow.ellipsis),
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

    // Dependent dropdown options:
    final availableBrands =
        _selectedCategory == 'All'
            ? _brands
            : {
              'All',
              ..._allProducts
                  .where((p) => p['category'] == _selectedCategory)
                  .map((p) => p['brand']?.toString() ?? '')
                  .where((b) => b.isNotEmpty),
            };

    final availableCategories =
        _selectedBrand == 'All'
            ? _categories
            : {
              'All',
              ..._allProducts
                  .where((p) => p['brand'] == _selectedBrand)
                  .map((p) => p['category']?.toString() ?? '')
                  .where((c) => c.isNotEmpty),
            };

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
            onPressed: () => setState(() => _showFilters = !_showFilters),
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
                    // Brand & Category
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Brand',
                            value: _selectedBrand,
                            items: availableBrands,
                            onChanged: (val) {
                              setState(() {
                                _selectedBrand = val ?? 'All';
                                // if current category not in new list, reset
                                if (!availableCategories.contains(
                                  _selectedCategory,
                                )) {
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
                            value: _selectedCategory,
                            items: availableCategories,
                            onChanged: (val) {
                              setState(() {
                                _selectedCategory = val ?? 'All';
                                // if current brand not in new list, reset
                                if (!availableBrands.contains(_selectedBrand)) {
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
                    // Count & Clear
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
                child: Column(
                  children: [
                    Icon(Icons.search_off, color: Colors.white54, size: 50),
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
              )
            else
              Column(
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _paginatedProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
