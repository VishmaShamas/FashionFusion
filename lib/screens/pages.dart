// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:fashion_fusion/constants/colors.dart';
// import 'package:fashion_fusion/widgets/ui/loader.dart';
// import 'package:fashion_fusion/widgets/cards/product_card.dart';

// class ProductPage extends StatefulWidget {
//   const ProductPage({super.key});

//   @override
//   State<ProductPage> createState() => _ProductPageState();
// }

// class _ProductPageState extends State<ProductPage> {
//   final int _pageSize = 30;
//   int _currentPage = 1;
//   bool _loading = true;

//   DocumentSnapshot? _lastSnapshot;
//   bool _hasMore = true;

//   List<Map<String, dynamic>> _products = [];
//   List<Map<String, dynamic>> _filtered = [];

//   Set<String> _brands = {'All'};
//   Set<String> _categories = {'All'};

//   String _selBrand = 'All';
//   String _selCat = 'All';
//   String _search = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadPage(1);
//   }

//   Future<void> _loadPage(int page) async {
//     if (!_hasMore && page > _currentPage) return;

//     setState(() => _loading = true);
//     Query q = FirebaseFirestore.instance
//         .collection('products')
//         .orderBy('title')
//         .limit(_pageSize);

//     if (page > _currentPage && _lastSnapshot != null) {
//       q = q.startAfterDocument(_lastSnapshot!);
//     } else if (page < _currentPage) {
//       // Reset to first page
//       _lastSnapshot = null;
//       _products.clear();
//       _hasMore = true;
//     }

//     final snap = await q.get();
//     final docs = snap.docs;

//     if (docs.isEmpty && page > 1) return;

//     final items = docs.map((d) => {'id': d.id, ...d.data()}).toList();

//     setState(() {
//       if (page == _currentPage) {
//         _products = items;
//       } else if (page > _currentPage) {
//         _products = items;
//         _currentPage = page;
//         _lastSnapshot = docs.isNotEmpty ? docs.last : _lastSnapshot;
//       }

//       if (docs.length < _pageSize) _hasMore = false;

//       // refresh filters
//       _brands = {'All', ..._products.map((p) => p['brand'].toString())};
//       _categories = {'All', ..._products.map((p) => p['category'].toString())};

//       _applyFilters();
//       _loading = false;
//     });
//   }

//   void _applyFilters() {
//     _filtered = _products.where((p) {
//       final matchBrand = _selBrand == 'All' || p['brand'] == _selBrand;
//       final matchCat = _selCat == 'All' || p['category'] == _selCat;
//       final matchSearch = _search.isEmpty ||
//           p['title'].toString().toLowerCase().contains(_search.toLowerCase()) ||
//           p['description']?.toString().toLowerCase().contains(_search.toLowerCase()) == true;
//       return matchBrand && matchCat && matchSearch;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Shop Products'),
//         backgroundColor: AppColors.darkScaffoldColor,
//       ),
//       backgroundColor: AppColors.darkScaffoldColor,
//       body: Column(
//         children: [
//           // Filters
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(child: _buildDropdown('Brand', _selBrand, _brands, (v) {
//                   setState(() {
//                     _selBrand = v!;
//                     _applyFilters();
//                   });
//                 })),
//                 const SizedBox(width: 8),
//                 Expanded(child: _buildDropdown('Category', _selCat, _categories, (v) {
//                   setState(() {
//                     _selCat = v!;
//                     _applyFilters();
//                   });
//                 })),
//               ],
//             ),
//           ),

//           // Search
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search products...',
//                 fillColor: AppColors.samiDarkColor,
//                 filled: true,
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//               ),
//               style: const TextStyle(color: Colors.white),
//               onChanged: (val) {
//                 setState(() {
//                   _search = val;
//                   _applyFilters();
//                 });
//               },
//             ),
//           ),

//           // Pagination buttons
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Wrap(
//               spacing: 8,
//               children: List.generate(
//                 (_currentPage + (_hasMore ? 1 : 0)),
//                 (i) => ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _currentPage == i + 1 ? AppColors.primary : AppColors.samiDarkColor,
//                   ),
//                   onPressed: () => _loadPage(i + 1),
//                   child: Text('${i + 1}'),
//                 ),
//               ),
//             ),
//           ),

//           // Product list
//           Expanded(
//             child: _loading
//                 ? const Center(child: CustomLoadingAnimation())
//                 : _filtered.isEmpty
//                     ? const Center(child: Text('No products', style: TextStyle(color: Colors.white)))
//                     : GridView.builder(
//                         padding: const EdgeInsets.all(8),
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           mainAxisSpacing: 8,
//                           crossAxisSpacing: 8,
//                           childAspectRatio: 0.62,
//                         ),
//                         itemCount: _filtered.length,
//                         itemBuilder: (_, idx) => ProductCard(product: _filtered[idx], parentContext: context),
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDropdown(String label, String value, Set<String> items, void Function(String?) onChanged) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       decoration: InputDecoration(
//         labelText: label,
//         filled: true,
//         fillColor: AppColors.samiDarkColor,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//       ),
//       items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
//       onChanged: onChanged,
//       dropdownColor: AppColors.samiDarkColor,
//       style: const TextStyle(color: Colors.white),
//     );
//   }
// }
// //
