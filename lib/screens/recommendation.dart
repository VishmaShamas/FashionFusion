import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import 'package:fashion_fusion/constants/colors.dart';

class PersonalizedRecommendationPage extends StatefulWidget {
  const PersonalizedRecommendationPage({super.key});

  @override
  State<PersonalizedRecommendationPage> createState() =>
      _PersonalizedRecommendationPageState();
}

class _PersonalizedRecommendationPageState extends State<PersonalizedRecommendationPage> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  double _scanPosition = 0;
  String _bodyType = 'Athletic';
  List<String> _recommendedOutfits = [];
  List<String> _trendingStyles = [];

  late final ImageLabeler _labeler;

  final Map<String, List<String>> _bodyTypeOutfits = {
    'Athletic': [
      'Fitted T-shirts with Slim Jeans',
      'Tailored Blazers',
      'Athleisure Wear'
    ],
    'Slim': [
      'Layered Outfits',
      'Fitted Sweaters',
      'Straight-leg Pants'
    ],
    'Muscular': [
      'Stretch-fit Shirts',
      'Relaxed Fit Jeans',
      'V-neck T-shirts'
    ],
    'Stocky': [
      'Dark Colored Outfits',
      'Vertical Stripes',
      'Single-breasted Jackets'
    ],
  };

  final List<String> _trendingOutfits = [
    'Monochromatic Streetwear',
    'Retro Sportswear',
    'Techwear Essentials',
    'Minimalist Business Casual',
    'Urban Utility Wear'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserBodyType();
    _loadTrendingStyles();

    final options = ImageLabelerOptions(confidenceThreshold: 0.6);
    _labeler = ImageLabeler(options: options);
  }

  void _fetchUserBodyType() {
    setState(() => _bodyType = 'Athletic');
  }

  void _loadTrendingStyles() {
    setState(() {
      _trendingStyles = [...?_bodyTypeOutfits[_bodyType], ..._trendingOutfits];
    });
  }

  void _changeBodyType(String newType) {
    setState(() {
      _bodyType = newType;
      _loadTrendingStyles();
    });
  }

  Future<void> _pickAndAnalyzeImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _isAnalyzing = true;
        _recommendedOutfits.clear();
      });

      for (int i = 0; i < 5; i++) {
        setState(() => _scanPosition = (i % 2 == 0) ? 1.0 : 0.0);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final inputImage = InputImage.fromFile(File(pickedFile.path));
      final labels = await _labeler.processImage(inputImage);

      final clothingLabels = labels.where((label) =>
        label.label.toLowerCase().contains('shirt') ||
        label.label.toLowerCase().contains('pant') ||
        label.label.toLowerCase().contains('jacket') ||
        label.label.toLowerCase().contains('suit') ||
        label.label.toLowerCase().contains('wear') ||
        label.label.toLowerCase().contains('clothing')
      ).toList();

      clothingLabels.sort((a, b) => b.confidence.compareTo(a.confidence));
      final topLabels = clothingLabels.take(3).map((e) => e.label).toList();

      final recommendations = topLabels.map((label) {
        return '$_bodyType $label outfit';
      }).toList();

      setState(() {
        _isAnalyzing = false;
        _recommendedOutfits = recommendations;
      });

    } catch (e) {
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing image: ${e.toString()}')),
      );
    }
  }

  void _searchByDescription(String query) {
    setState(() {
      _selectedImage = null;
      _recommendedOutfits = [
        'Casual $query outfit',
        'Formal $query look',
        'Streetwear inspired by $query'
      ];
    });
  }

  void _showBodyTypeSelector() {
    final bodyTypes = ['Athletic', 'Slim', 'Muscular', 'Stocky'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.samiDarkColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Your Body Type',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...bodyTypes.map((type) {
              return ListTile(
                title: Text(type, style: const TextStyle(color: Colors.white)),
                trailing: _bodyType == type
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

  void _findSimilarInWardrobe() {
    setState(() {
      _recommendedOutfits = [
        'Similar items in your wardrobe',
        'Matching accessories',
        'Complementary colors'
      ];
    });
  }

  void _findSimilarProducts() {
    setState(() {
      _recommendedOutfits = [
        'Similar products from our partners',
        'Recommended brands',
        'Trending items matching your style'
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Style Assistant', style: TextStyle(color: Colors.white)),
            floating: true,
            backgroundColor: AppColors.darkScaffoldColor,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildBodyTypeSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_selectedImage != null) _buildImageAnalysisSection(),
          if (_recommendedOutfits.isNotEmpty) _buildRecommendedOutfits(),
          _buildTrendingStylesSection(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.samiDarkColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Describe your outfit needs...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) _searchByDescription(value);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white70),
            onPressed: _pickAndAnalyzeImage,
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Body Type: ', style: TextStyle(color: Colors.white, fontSize: 16)),
            Text(_bodyType, style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.accessibility_new_rounded, color: Colors.white70),
              onPressed: _showBodyTypeSelector,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Recommended for $_bodyType body type:', style: TextStyle(color: Colors.white.withOpacity(0.8))),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _bodyTypeOutfits[_bodyType]!.map((outfit) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text(outfit, style: TextStyle(color: AppColors.cardBackgroundColor)),
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildImageAnalysisSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                if (_isAnalyzing)
                  Positioned(
                    top: _scanPosition * 180,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 48,
                      height: 2,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isAnalyzing)
              const Text('Analyzing image...', style: TextStyle(color: Colors.white70)),
            if (!_isAnalyzing && _selectedImage != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _findSimilarInWardrobe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Find in Wardrobe'),
                  ),
                  ElevatedButton(
                    onPressed: _findSimilarProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.samiDarkColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Shop Similar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  SliverList _buildRecommendedOutfits() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: _buildOutfitCard(_recommendedOutfits[index]),
        ),
        childCount: _recommendedOutfits.length,
      ),
    );
  }

  SliverToBoxAdapter _buildTrendingStylesSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trending Styles for You',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _trendingStyles.length,
                itemBuilder: (context, index) => Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  child: _buildTrendingStyleCard(_trendingStyles[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitCard(String outfit) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.samiDarkColor,
        image: DecorationImage(
          image: NetworkImage(_getOutfitImageUrl(outfit)),
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
            child: Text(
              outfit,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingStyleCard(String style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.samiDarkColor,
              image: DecorationImage(
                image: NetworkImage(_getOutfitImageUrl(style)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          style,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getOutfitImageUrl(String outfit) {
    return "https://source.unsplash.com/random/300x300/?men,fashion,${outfit.toLowerCase().replaceAll(' ', ',')}";
  }
}
