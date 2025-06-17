// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import '../constants/colors.dart';
// import '../services/vision_api_service.dart';

// class WardrobeItem {
//   final String id, imageUrl, category;
//   final String? note;
//   final DateTime createdAt;

//   WardrobeItem({
//     required this.id,
//     required this.imageUrl,
//     required this.category,
//     this.note,
//     required this.createdAt,
//   });

//   factory WardrobeItem.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return WardrobeItem(
//       id: doc.id,
//       imageUrl: data['imageUrl'],
//       category: data['category'],
//       note: data['note'],
//       createdAt: (data['createdAt'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toMap() => {
//     'imageUrl': imageUrl,
//     'category': category,
//     'note': note,
//     'createdAt': createdAt,
//   };
// }

// class WardrobePage extends StatefulWidget {
//   const WardrobePage({super.key});
//   @override
//   State<WardrobePage> createState() => _WardrobePageState();
// }

// class _WardrobePageState extends State<WardrobePage> {
//   final items = <WardrobeItem>[];
//   final categories = ['All','Shirts','Jeans','Shoes','Jackets','Accessories','Others'];
//   String selectedCategory = 'All';
//   String searchQuery = '';
//   final picker = ImagePicker();
//   final storage = FirebaseStorage.instance;
//   final firestore = FirebaseFirestore.instance;
//   final auth = FirebaseAuth.instance;

//   late VisionApiService visionService;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     VisionApiService.create('assets/cred/wardrobe.json')
//       .then((svc) {
//         visionService = svc;
//         _loadWardrobeItems();
//       })
//       .catchError((e) {
//         _showError('Vision API init failed: $e');
//         setState(() => isLoading = false);
//       });
//   }

//   Future<void> _loadWardrobeItems() async {
//     final uid = auth.currentUser?.uid;
//     if (uid == null) {
//       setState(() => isLoading = false);
//       return;
//     }

//     try {
//       final snapshot = await firestore
//         .collection('users')
//         .doc(uid)
//         .collection('wardrobe')
//         .orderBy('createdAt', descending: true)
//         .get();

//       items.clear();
//       items.addAll(snapshot.docs.map(WardrobeItem.fromFirestore));
//     } catch (e) {
//       _showError('Failed to load items: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _addPhoto() async {
//     final xfile = await picker.pickImage(source: ImageSource.gallery);
//     if (xfile == null) return;

//     setState(() => isLoading = true);
//     try {
//       final file = File(xfile.path);
//       final cat = await visionService.categorizeClothingItem(file);

//       final result = await showDialog<Map<String,String>>(
//         // ignore: use_build_context_synchronously
//         context: context,
//         builder: (_) => _AddItemDialog(
//           initialCategory: cat.toString(),
//           categories: categories.where((c) => c!='All').toList(),
//         ),
//       );
//       if (result == null) return;

//       final timestamp = DateTime.now();
//       final uid = auth.currentUser!.uid;
//       final dest = 'wardrobe/$uid/$timestamp.jpg';
//       final ref = storage.ref().child(dest);
//       await ref.putFile(file);
//       final url = await ref.getDownloadURL();

//       final docRef = await firestore
//         .collection('users')
//         .doc(uid)
//         .collection('wardrobe')
//         .add({
//           'imageUrl': url,
//           'category': result['category'],
//           'note': result['note'] ?? '',
//           'createdAt': timestamp,
//         });

//       items.insert(0, WardrobeItem(
//         id: docRef.id,
//         imageUrl: url,
//         category: result['category']!,
//         note: result['note'],
//         createdAt: timestamp,
//       ));
//     } catch (e) {
//       _showError('Add photo failed: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _deleteItem(WardrobeItem item) async {
//     setState(() => isLoading = true);
//     try {
//       final uid = auth.currentUser!.uid;
//       await firestore
//         .collection('users')
//         .doc(uid)
//         .collection('wardrobe')
//         .doc(item.id)
//         .delete();
//       await storage.refFromURL(item.imageUrl).delete();
//       items.removeWhere((i) => i.id == item.id);
//     } catch (e) {
//       _showError('Delete failed: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.red),
//     );
//   }

//   List<WardrobeItem> get filteredItems => items.where((i) {
//     final categoryMatch = selectedCategory=='All' || i.category==selectedCategory;
//     final searchMatch = searchQuery.isEmpty ||
//       i.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
//       (i.note?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
//     return categoryMatch && searchMatch;
//   }).toList();

//   @override
//   Widget build(BuildContext ctx) {
//     return Scaffold(
//       backgroundColor: AppColors.backroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backroundColor,
//         elevation: 0,
//         title: const Text('Wardrobe', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add_a_photo, color: AppColors.primary),
//             onPressed: _addPhoto,
//           )
//         ],
//       ),
//       body: isLoading
//         ? const Center(child: CircularProgressIndicator())
//         : Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Column(
//               children: [
//                 _buildSearchBar(),
//                 const SizedBox(height: 12),
//                 _buildCategoryChips(),
//                 const SizedBox(height: 14),
//                 _buildWardrobeGrid(),
//               ],
//             ),
//           ),
//     );
//   }

//   Widget _buildSearchBar() => Container(
//     decoration: BoxDecoration(
//       color: AppColors.samiDarkColor,
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: TextField(
//       style: const TextStyle(color: Colors.white),
//       decoration: const InputDecoration(
//         hintText: 'Search your wardrobe...',
//         hintStyle: TextStyle(color: Colors.white54),
//         prefixIcon: Icon(Icons.search, color: Colors.white54),
//         border: InputBorder.none,
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),
//       onChanged: (v) => setState(() => searchQuery = v),
//     ),
//   );

//   Widget _buildCategoryChips() => SingleChildScrollView(
//     scrollDirection: Axis.horizontal,
//     child: Row(
//       children: categories.map((cat) {
//         final sel = cat == selectedCategory;
//         return Container(
//           margin: const EdgeInsets.only(right: 8),
//           child: ChoiceChip(
//             label: Text(cat),
//             selected: sel,
//             selectedColor: AppColors.primary,
//             backgroundColor: AppColors.samiDarkColor,
//             labelStyle: TextStyle(color: sel? Colors.white : Colors.white70, fontWeight: FontWeight.w500),
//             onSelected: (_) => setState(() => selectedCategory = cat),
//           ),
//         );
//       }).toList(),
//     ),
//   );

//   Widget _buildWardrobeGrid() {
//     final list = filteredItems;
//     if (list.isEmpty) {
//       return Expanded(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Icon(Icons.checkroom, size: 60, color: Colors.white24),
//               SizedBox(height: 8),
//               Text('No items found', style: TextStyle(color: Colors.white54)),
//             ],
//           ),
//         ),
//       );
//     }

//     return Expanded(
//       child: GridView.builder(
//         itemCount: list.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
//         itemBuilder: (_, idx) {
//           final item = list[idx];
//           return GestureDetector(
//             onLongPress: () => _deleteItem(item),
//             child: Container(
//               decoration: BoxDecoration(color: AppColors.samiDarkColor, borderRadius: BorderRadius.circular(12)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                       child: Image.network(item.imageUrl, width: double.infinity, fit: BoxFit.cover),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(item.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
//                         if (item.note != null && item.note!.isNotEmpty)
//                           Text(item.note!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _AddItemDialog extends StatefulWidget {
//   final String initialCategory;
//   final List<String> categories;
//   const _AddItemDialog({ required this.initialCategory, required this.categories });

//   @override
//   State<_AddItemDialog> createState() => _AddItemDialogState();
// }

// class _AddItemDialogState extends State<_AddItemDialog> {
//   late String category;
//   final noteCtrl = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     category = widget.initialCategory;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: AppColors.samiDarkColor,
//       title: const Text('Add to Wardrobe', style: TextStyle(color: Colors.white)),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           DropdownButtonFormField<String>(
//             value: category,
//             items: widget.categories.map((c) {
//               return DropdownMenuItem(
//                 value: c, child: Text(c, style: const TextStyle(color: Colors.white)),
//               );
//             }).toList(),
//             onChanged: (v) => setState(() => category = v!),
//             decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.white70)),
//             dropdownColor: AppColors.samiDarkColor,
//             style: const TextStyle(color: Colors.white),
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             controller: noteCtrl,
//             style: const TextStyle(color: Colors.white),
//             decoration: const InputDecoration(labelText: 'Note (optional)', labelStyle: TextStyle(color: Colors.white70)),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(child: const Text('Cancel', style: TextStyle(color: Colors.white54)), onPressed: () => Navigator.pop(context)),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//           onPressed: () => Navigator.pop(context, {'category': category, 'note': noteCtrl.text}),
//           child: const Text('Add', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../constants/colors.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final ImagePicker picker = ImagePicker();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> wardrobeItems = [];
  bool isLoading = true;

  final List<String> categories = [
    'Shirts',
    'Jeans',
    'Shoes',
    'Jackets',
    'Accessories',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _loadWardrobe();
  }

  Future<void> _loadWardrobe() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await firestore
              .collection('users')
              .doc(uid)
              .collection('wardrobe')
              .get();

      setState(() {
        wardrobeItems =
            snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                'imageUrl': doc['imageUrl'],
                'category': doc['category'],
                'note': doc['note'],
              };
            }).toList();
      });
    } catch (e) {
      _showError('Error loading wardrobe: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addWardrobeItem() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final fileSize = await file.length();

    if (fileSize > 1 * 1024 * 1024) {
      _showError('File too large! Please select image < 1MB.');
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AddWardrobeDialog(categories: categories),
    );

    if (result == null) return;

    final selectedCategory = result['category'];
    final note = result['note'];

    setState(() => isLoading = true);
    try {
      final uid = auth.currentUser!.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = storage.ref().child('wardrobe/$uid/$timestamp.jpg');
      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();

      final docRef = await firestore
          .collection('users')
          .doc(uid)
          .collection('wardrobe')
          .add({
            'imageUrl': imageUrl,
            'category': selectedCategory,
            'note': note,
          });

      setState(() {
        wardrobeItems.insert(0, {
          'id': docRef.id,
          'imageUrl': imageUrl,
          'category': selectedCategory,
          'note': note,
        });
      });
    } catch (e) {
      _showError('Failed to upload: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteWardrobeItem(String id, String imageUrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Item"),
            content: const Text("Are you sure you want to delete this item?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);
    try {
      final uid = auth.currentUser!.uid;
      await firestore
          .collection('users')
          .doc(uid)
          .collection('wardrobe')
          .doc(id)
          .delete();

      await storage.refFromURL(imageUrl).delete();

      setState(() {
        wardrobeItems.removeWhere((item) => item['id'] == id);
      });
    } catch (e) {
      _showError('Failed to delete: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkScaffoldColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("My Wardrobe", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _addWardrobeItem,
            icon: const Icon(Icons.add_a_photo, color: AppColors.primary),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : wardrobeItems.isEmpty
              ? const Center(
                child: Text(
                  "No items yet",
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: wardrobeItems.length,
                itemBuilder: (context, index) {
                  final item = wardrobeItems[index];
                  return GestureDetector(
                    onLongPress:
                        () => _deleteWardrobeItem(item['id'], item['imageUrl']),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.samiDarkColor,
                        image: DecorationImage(
                          image: NetworkImage(item['imageUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item['category'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if ((item['note'] ?? '').isNotEmpty)
                                  Text(
                                    item['note'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
                },
              ),
    );
  }
}

class _AddWardrobeDialog extends StatefulWidget {
  final List<String> categories;
  const _AddWardrobeDialog({required this.categories});

  @override
  State<_AddWardrobeDialog> createState() => _AddWardrobeDialogState();
}

class _AddWardrobeDialogState extends State<_AddWardrobeDialog> {
  String? selectedCategory;
  final TextEditingController noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.samiDarkColor,
      title: const Text("Add Item", style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              labelText: "Category",
              labelStyle: TextStyle(color: Colors.white70),
            ),
            dropdownColor: AppColors.samiDarkColor,
            style: const TextStyle(color: Colors.white),
            items:
                widget.categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
            onChanged: (v) => setState(() => selectedCategory = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Note",
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'category': selectedCategory,
              'note': noteCtrl.text,
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text("Add"),
        ),
      ],
    );
  }
}
