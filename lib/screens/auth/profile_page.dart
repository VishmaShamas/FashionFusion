import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_fusion/constants/colors.dart';
import 'package:fashion_fusion/screens/liked_products.dart';
import 'package:fashion_fusion/screens/wardrobe_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_fusion/screens/auth/login_page.dart';
import 'package:fashion_fusion/widgets/ui/loader.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Map<String, dynamic>? userData;
  List<dynamic> wardrobe = [];
  List<dynamic> likedProducts = [];
  List<dynamic> preferences = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email);

    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      userData = docSnapshot.data();
    }

    // Fetch wardrobe
    final wardrobeSnapshot =
        await userDoc.collection('wardrobe').limit(10).get();
    wardrobe = wardrobeSnapshot.docs.map((doc) => doc.data()).toList();

    // Fetch liked products
    final likedSnapshot =
        await userDoc.collection('likedProducts').limit(10).get();
    likedProducts = likedSnapshot.docs.map((doc) => doc.data()).toList();

    // Fetch preferences
    final prefSnapshot =
        await userDoc.collection('preferences').limit(10).get();
    preferences =
        prefSnapshot.docs
            .map((doc) => doc.data())
            .toList(); // Assuming doc ID is preference name

    setState(() {
      _isLoading = false;
    });
  }

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Widget _buildBodyTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Body Type: ',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              userData!['bodyType'],
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.accessibility_new_rounded,
                color: Colors.white70,
              ),
              onPressed: _showBodyTypeSelector,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ignore: deprecated_member_use
        Text(
          'Recommended for ${userData!['bodyType']} body type:',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showBodyTypeSelector() {
    final bodyTypes = ['Athletic', 'Slim', 'Muscular', 'Stocky'];

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
                const Text(
                  'Select Your Body Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...bodyTypes.map((type) {
                  return ListTile(
                    title: Text(
                      type,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing:
                        userData!['bodyType'] == type
                            ? Icon(Icons.check, color: AppColors.primary)
                            : null,
                    onTap: () {
                      _changeBodyType(type);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: SafeArea(
        child: FutureBuilder(
          future: _getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CustomLoadingAnimation());
            }
            user = snapshot.data;
            if (user == null) {
              return _buildNotSignedIn();
            }
            return _buildProfileContent(user!);
          },
        ),
      ),
    );
  }

  Widget _buildNotSignedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome to Fashion Fusion',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your profile and wardrobe',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ).animate().fadeIn().scale(),
        ],
      ),
    );
  }

  Widget _buildProfileContent(User user) {
    if (_isLoading) {
      return const Center(child: CustomLoadingAnimation());
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.darkScaffoldColor,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    GestureDetector(
                      onTap: _editProfile,
                      child: Hero(
                        tag: 'profile-avatar',
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(
                            'assets/avatar/avatar.png',
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Text(
                  userData?['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userData?['email'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 40),
                // _buildTrendingStyles(),
                // const SizedBox(height: 32),
                _buildSectionTitle("Your Style Preferences", () {}),
                const SizedBox(height: 16),
                _buildStylePreferences(),
                const SizedBox(height: 32),
                _buildSectionTitle("Your Wardrobe", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WardrobePage()),
                  );
                }),
                const SizedBox(height: 16),
                _buildWardrobeCarousel(),
                const SizedBox(height: 32),
                _buildSectionTitle("Liked Items", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LikedProducts()),
                  );
                }),
                const SizedBox(height: 16),
                _buildLikedItemsGrid(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingStyles() {
    final List<Map<String, dynamic>> trendingStyles = [
      {
        'title': 'Streetwear Essentials',
        'image':
            'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'likes': '1.2k',
      },
      {
        'title': 'Minimalist Business',
        'image':
            'https://images.unsplash.com/photo-1539533018447-63fcce2678e4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'likes': '856',
      },
      {
        'title': 'Athleisure Vibes',
        'image':
            'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'likes': '1.5k',
      },
      {
        'title': 'Urban Utility',
        'image':
            'https://images.unsplash.com/photo-1551232864-3f0890e580d9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'likes': '932',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Preferences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: trendingStyles.length,
            itemBuilder: (context, index) {
              final style = trendingStyles[index];
              return _buildTrendingStyleCard(style);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingStyleCard(Map<String, dynamic> style) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.samiDarkColor,
                image: DecorationImage(
                  image: NetworkImage(style['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          style['likes'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              style['title'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Trending this week',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("${likedProducts.length}", "Liked Items"),
        _buildStatItem("${wardrobe.length}", "Wardrobe"),
        _buildStatItem("${preferences.length}", "Preferences"),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.edit,
          label: "Edit Profile",
          color: AppColors.primary,
          onPressed: _editProfile,
        ),
        _buildActionButton(
          icon: Icons.logout,
          label: "Sign Out",
          color: Colors.redAccent,
          onPressed: _confirmSignOut,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        shadowColor: color.withOpacity(0.3),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onPressed) {
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
        TextButton(
          onPressed: onPressed,
          child: Text(
            "See all",
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStylePreferences() {
    if (preferences.isEmpty) {
      return _buildEmptyMessage("No preferences added yet.");
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          preferences.map((pref) {
            return Chip(
              avatar: Icon(Icons.style, size: 18, color: Colors.white),
              label: Text(pref, style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.primary.withOpacity(0.2),
              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildStyleChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.primary.withOpacity(0.2),
      side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildLikedItemsGrid() {
    if (likedProducts.isEmpty) {
      return _buildEmptyMessage("No liked products yet.");
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: likedProducts.length,
        itemBuilder: (context, index) {
          final item = likedProducts[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.samiDarkColor,
              image: DecorationImage(
                image: NetworkImage(item['image'] ?? ''),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.favorite, color: Colors.red, size: 24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: user?.displayName ?? '');
    nameController.addListener(() {
      final changedName =
          nameController.text.trim() != (user?.displayName ?? '');
      setState(() {
        _hasChanges = changedName || _selectedImage != null;
      });
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.samiDarkColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
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
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.samiDarkColor,
                    child: const Icon(Icons.camera_alt, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      !_hasChanges || _isSaving
                          ? null
                          : () async {
                            setState(() {
                              _isSaving = true;
                            });

                            final newName = nameController.text.trim();
                            String? imageUrl;

                            final updates = <String, dynamic>{};

                            if (newName.isNotEmpty &&
                                newName != user!.displayName) {
                              await user!.updateDisplayName(newName);
                              updates['name'] = newName;
                            }

                            await user!.reload();
                            user = FirebaseAuth.instance.currentUser;

                            if (updates.isNotEmpty) {
                              updates['email'] = user!.email;
                              final userRef = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user!.uid);
                              await userRef.set(
                                updates,
                                SetOptions(merge: true),
                              );
                            }

                            setState(() {
                              _isSaving = false;
                              _selectedImage = null;
                              _hasChanges = false;
                            });

                            if (context.mounted) Navigator.pop(context);
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _hasChanges = true; // image picked → form has changes
      });
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.samiDarkColor,
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to sign out?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  Widget _buildWardrobeCarousel() {
    if (wardrobe.isEmpty) {
      return _buildEmptyMessage("No wardrobe items uploaded yet.");
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: wardrobe.length,
        itemBuilder: (context, index) {
          final item = wardrobe[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.samiDarkColor,
              image: DecorationImage(
                image: NetworkImage(item['image'] ?? ''),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    item['title'] ?? 'Outfit',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  void _changeBodyType(String type) {
    // change body tpye in firebase
    setState(() {
      _isLoading = true;
    });
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email);
    userDoc.update({'bodyType': type}).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }
}
