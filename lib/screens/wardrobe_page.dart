import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:fashion_fusion/constants/colors.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'package:http/http.dart' as http;

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;
  final ImageLabeler _labeler = ImageLabeler(options: ImageLabelerOptions());
  final double _scanPosition = 0;
  final List<String> _categories = [
    // keep exactly the same spelling & case as backend CATS
    'shirt',
    'polo',
    't-shirt',
    'denim jacket',
    'jeans',
    'pants',
    'cargo pants',
    'sweater',
    'jacket',
    'shawl',
    'kurta',
    'kurta pajama',
    'shalwar qameez',
    'waistcoat',
    'formal suit',
    'sportswear',
    'tank top',
    'vest',
    'achkan',
    'prince coat',
    'shorts',
    'hoodie',
  ];

  @override
  void initState() {
    super.initState();
    _loadWardrobeItems();
  }

  String _titleCase(String txt) =>
      txt.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  String _selectedCategory = 'All';
  final List<Map<String, dynamic>> _wardrobeItems = [];

  void _loadWardrobeItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.email);
    final snapshot = await docRef.get();

    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data()!;
      final List wardrobe = data['wardrobe'] ?? [];

      setState(() {
        _wardrobeItems.clear();
        for (var item in wardrobe) {
          _wardrobeItems.add({
            'imageUrl': (item['imageUrl']),
            'category': item['category'],
            'uploadDate': item['uploadDate'],
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.darkScaffoldColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.darkScaffoldColor,
                title: const Text(
                  'My Wardrobe',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryFilter(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildWardrobeList(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _pickAndAnalyzeImage,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),

        // ✅ Loader overlay
        if (_isUploading)
          Container(
            color: Colors.black.withOpacity(0.6),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            ['All', ..._categories].map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(
                    _titleCase(category),
                    style: TextStyle(
                      color:
                          _selectedCategory == category
                              ? AppColors.darkScaffoldColor
                              : Colors.white70,
                      fontWeight:
                          _selectedCategory == category
                              ? FontWeight.w900
                              : FontWeight.w600,
                    ),
                  ),
                  selected: _selectedCategory == category,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.cardBackgroundColor,
                  showCheckmark: false,
                  shadowColor: AppColors.primary,
                  selectedShadowColor: AppColors.primary,
                  surfaceTintColor: AppColors.darkScaffoldColor,
                  side: BorderSide.none,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : 'All';
                    });
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (_selectedCategory != 'All')
          TextButton(
            onPressed: () => setState(() => _selectedCategory = 'All'),
            child: Text(
              "Clear filter",
              style: TextStyle(color: AppColors.primary, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildWardrobeGridItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _showItemDetails(item),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          'http://172.20.10.12:8000${item['imageUrl']}',
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.broken_image),
        ),
      ),
    );
  }

  Widget _buildWardrobeList() {
    final filteredItems =
        _selectedCategory == 'All'
            ? _wardrobeItems
            : _wardrobeItems
                .where((item) => item['category'] == _selectedCategory)
                .toList();

    if (filteredItems.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ignore: deprecated_member_use
              Icon(
                Icons.photo_library_outlined,
                size: 60,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No clothing items added',
                // ignore: deprecated_member_use
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to add items',
                // ignore: deprecated_member_use
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = filteredItems[index];
          return _buildWardrobeGridItem(item);
        }, childCount: filteredItems.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
      ),
    );
  }

  Widget _buildWardrobeItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.samiDarkColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'http://172.20.10.12:8000${item['imageUrl']}',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndAnalyzeImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      // ---------- size & blur checks ----------
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        _showErrorDialog(
          'Image too large',
          'Please select an image smaller than 5 MB',
        );
        return;
      }
      if (await _isImageBlurry(imageFile)) {
        _showErrorDialog('Blurry image', 'Please select a clear image');
        return;
      }

      setState(() {
        _selectedImage = imageFile;
        _isUploading = true;
      });

      // ---------- send to backend ----------
      const apiUrl = 'http://172.20.10.12:8000/upload-wardrobe'; // your backend
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');

      final request =
          http.MultipartRequest('POST', Uri.parse(apiUrl))
            ..fields['user_id'] = user.uid ?? ''
            ..files.add(
              await http.MultipartFile.fromPath('image', imageFile.path),
            );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() => _isUploading = false);

      final resJson =
          response.body.isNotEmpty
              ? Map<String, dynamic>.from(json.decode(response.body))
              : {};

      if (response.statusCode != 200) {
        _showErrorDialog('Invalid image', resJson['reason'] ?? 'Unknown error');
        return;
      }

      if (resJson['valid'] == false) {
        _showErrorDialog('Invalid image', resJson['reason'] ?? 'Unknown error');
        return;
      }

      // ---------- success ----------
      final backendCategory =
          (resJson['category'] ?? 'shirt').toString().toLowerCase();
      final savedImagePath =
          resJson['saved_image']; // e.g. assets/{user.uid}/item1.png
      await _showUploadConfirmation(backendCategory, savedImagePath);
      // e.g., assets/userid/file.png
      // e.g., assets/userid/file.png
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorDialog('Error', 'Failed to process image: ${e.toString()}');
    }
  }

  String _capitalizeCategory(String category) {
    // Optionally beautify category names
    if (category.isEmpty) return category;
    return category[0].toUpperCase() + category.substring(1);
  }

  Future<bool> _isImageBlurry(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) return true;

      // Simple blur detection using variance of laplacian
      final width = image.width;
      final height = image.height;
      final pixels = image.getBytes();

      double sum = 0;
      double sumSquared = 0;
      final int numPixels = width * height;

      for (int i = 0; i < pixels.length; i += 4) {
        final r = pixels[i].toDouble();
        final g = pixels[i + 1].toDouble();
        final b = pixels[i + 2].toDouble();
        final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
        sum += luminance;
        sumSquared += luminance * luminance;
      }

      final mean = sum / numPixels;
      final variance = (sumSquared / numPixels) - (mean * mean);
      return variance < 100;
    } catch (e) {
      return true;
    }
  }

  String _mapDetectedItemToCategory(String detectedItem) {
    detectedItem = detectedItem.toLowerCase();

    if (detectedItem.contains('shirt') ||
        detectedItem.contains('top') ||
        detectedItem.contains('t-shirt')) {
      return 'Tops';
    } else if (detectedItem.contains('pant') ||
        detectedItem.contains('jean') ||
        detectedItem.contains('trouser')) {
      return 'Bottoms';
    } else if (detectedItem.contains('dress') ||
        detectedItem.contains('gown')) {
      return 'Dresses';
    } else if (detectedItem.contains('jacket') ||
        detectedItem.contains('coat') ||
        detectedItem.contains('hoodie')) {
      return 'Outerwear';
    } else if (detectedItem.contains('shoe') ||
        detectedItem.contains('sneaker') ||
        detectedItem.contains('boot')) {
      return 'Footwear';
    } else if (detectedItem.contains('accessory') ||
        detectedItem.contains('bag') ||
        detectedItem.contains('hat')) {
      return 'Accessories';
    } else if (detectedItem.contains('formal') ||
        detectedItem.contains('suit')) {
      return 'Formal';
    } else if (detectedItem.contains('casual')) {
      return 'Casual';
    } else if (detectedItem.contains('sport') ||
        detectedItem.contains('active')) {
      return 'Sportswear';
    }

    return 'Other';
  }

  Future<void> _showUploadConfirmation(
    String detectedCategory,
    String savedImagePath,
  ) async {
    String? selectedCategory = detectedCategory;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.samiDarkColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Confirm Upload",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'http://172.20.10.12:8000$savedImagePath',
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 24),
                  _buildCategoryDropdown(selectedCategory, (newValue) {
                    setState(() => selectedCategory = newValue);
                  }),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() => _isUploading = false);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedCategory == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                ),
                              );
                              return;
                            }

                            await _uploadWardrobeItem(
                              selectedCategory!,
                              savedImagePath,
                            );

                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Upload'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryDropdown(
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.darkScaffoldColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: AppColors.darkScaffoldColor,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white),
            items:
                _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(_titleCase(category)),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildColorDropdown(String? value, ValueChanged<String?> onChanged) {
    final colors = [
      'Black',
      'White',
      'Red',
      'Blue',
      'Green',
      'Yellow',
      'Pink',
      'Purple',
      'Brown',
      'Gray',
      'Beige',
      'Other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.darkScaffoldColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: AppColors.darkScaffoldColor,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white),
            items:
                colors.map((color) {
                  return DropdownMenuItem<String>(
                    value: color,
                    child: Text(_titleCase(color)),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _uploadWardrobeItem(String category, String imagePath) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('users').doc(user.email);

      await docRef.set({
        'wardrobe': FieldValue.arrayUnion([
          {
            'imageUrl': imagePath,
            'category': category,
            'uploadDate': DateTime.now().toIso8601String(),
          },
        ]),
      }, SetOptions(merge: true));

      setState(() {
        _wardrobeItems.insert(0, {
          'imageUrl': imagePath,
          'category': category,
          'uploadDate': DateTime.now().toString().split(' ')[0],
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Item added to wardrobe!')),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorDialog('Upload Failed', e.toString());
    }
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.samiDarkColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'http://172.20.10.12:8000${item['imageUrl']}',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item['category'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['category'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Added on ${item['uploadDate']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.samiDarkColor,
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }
}
