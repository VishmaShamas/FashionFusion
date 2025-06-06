import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';

class WardrobeItem {
  final String imagePath;
  final String category;
  final String? note;

  WardrobeItem({required this.imagePath, required this.category, this.note});
}

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final List<WardrobeItem> _items = [];
  final List<String> _categories = [
    'All',
    'Shirts',
    'Jeans',
    'Shoes',
    'Jackets',
    'Accessories',
    'Others',
  ];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final ImagePicker _picker = ImagePicker();

  List<WardrobeItem> get _filteredItems {
    return _items.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _addPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String? selectedCat = await showDialog<String>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          String? tempCat = _categories.length > 1 ? _categories[1] : 'Shirts';
          TextEditingController noteController = TextEditingController();
          return AlertDialog(
            backgroundColor: AppColors.samiDarkColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Categorize Item', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  dropdownColor: AppColors.samiDarkColor,
                  value: tempCat,
                  items: _categories.where((c) => c != 'All').map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(color: Colors.white)),
                      )).toList(),
                  onChanged: (val) => tempCat = val,
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
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: AppColors.samiDarkColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(context, tempCat);
                  if (tempCat != null) {
                    setState(() {
                      _items.add(WardrobeItem(
                        imagePath: image.path,
                        category: tempCat!,
                        note: noteController.text.isNotEmpty ? noteController.text : null,
                      ));
                    });
                  }
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backroundColor,
        elevation: 0,
        title: const Text('Wardrobe', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo, color: AppColors.primary),
            tooltip: 'Add Photo',
            onPressed: _addPhoto,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.samiDarkColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search your wardrobe...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(height: 12),
            // Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  bool isSelected = (cat == _selectedCategory);
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.samiDarkColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            // Wardrobe grid
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checkroom, size: 60, color: Colors.white24),
                          const SizedBox(height: 8),
                          Text('No items found', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return _buildWardrobeCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardrobeCard(WardrobeItem item) {
    return GestureDetector(
      onTap: () {
        // Optionally show details or allow editing
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.samiDarkColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: item.imagePath.startsWith('http')
                    ? Image.network(item.imagePath, fit: BoxFit.cover, width: double.infinity)
                    : Image.file(File(item.imagePath), fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  if (item.note != null && item.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(item.note!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
