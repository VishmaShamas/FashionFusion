import 'dart:io';

import 'package:fashion_fusion/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_fusion/screens/auth/login_page.dart';
import 'package:fashion_fusion/widgets/ui/loader.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
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
          Icon(Icons.account_circle, size: 100, color: Colors.white.withOpacity(0.7)),
          const SizedBox(height: 24),
          const Text('Welcome to Fashion Fusion',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Sign in to access your profile and wardrobe',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ).animate().fadeIn().scale(),
        ],
      ),
    );
  }

  Widget _buildProfileContent(User user) {
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
                  colors: [AppColors.primary.withOpacity(0.8), AppColors.darkScaffoldColor],
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
                          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                          backgroundColor: AppColors.samiDarkColor,
                          child: user.photoURL == null
                              ? const Icon(Icons.person, size: 48, color: Colors.white70)
                              : null,
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
                Text(user.displayName ?? 'No Name',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(user.email ?? '',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 40),
                _buildSectionTitle("Your Style Preferences"),
                const SizedBox(height: 16),
                _buildStylePreferences(),
                const SizedBox(height: 32),
                _buildSectionTitle("Liked Items"),
                const SizedBox(height: 16),
                _buildLikedItemsGrid(),
                const SizedBox(height: 32),
                _buildSectionTitle("Your Wardrobe"),
                const SizedBox(height: 16),
                _buildWardrobeGrid(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("124", "Likes"),
        _buildStatItem("42", "Outfits"),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: Text("See all", style: TextStyle(color: AppColors.primary, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildStylePreferences() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStyleChip("Casual", Icons.weekend),
        _buildStyleChip("Formal", Icons.work),
        _buildStyleChip("Streetwear", Icons.streetview),
        _buildStyleChip("Bohemian", Icons.brush),
        _buildStyleChip("Minimalist", Icons.format_shapes),
      ],
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
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.samiDarkColor,
              image: DecorationImage(
                image: NetworkImage("https://source.unsplash.com/random/300x300/?fashion,clothing&$index"),
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

  Widget _buildWardrobeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.samiDarkColor,
            image: DecorationImage(
              image: NetworkImage("https://source.unsplash.com/random/300x300/?clothing,outfit&$index"),
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
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text("Outfit #${index + 1}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editProfile() async {
  final nameController = TextEditingController(text: user?.displayName ?? '');
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.samiDarkColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Edit Profile", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null) as ImageProvider?,
              child: _selectedImage == null && user?.photoURL == null
                  ? const Icon(Icons.camera_alt, color: Colors.white70)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Display Name',
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
            onPressed: () async {
              final newName = nameController.text.trim();
              String? imageUrl;

              // Upload profile image if selected
              if (_selectedImage != null) {
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('profile_pics/${user!.uid}.jpg');
                await ref.putFile(_selectedImage!);
                imageUrl = await ref.getDownloadURL();
              }

              // Update Firebase current user
              await user!.updateDisplayName(newName);
              if (imageUrl != null) {
                await user!.updatePhotoURL(imageUrl);
              }

              // Refresh user
              await user!.reload();
              user = FirebaseAuth.instance.currentUser;

              setState(() {
                _selectedImage = null; // Clear selected image after saving
              });

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    ),
  );
}

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.samiDarkColor,
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }
}
