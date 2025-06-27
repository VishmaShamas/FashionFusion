import 'dart:io';
import 'package:fashion_fusion/screens/wardrobe_recommendation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:fashion_fusion/screens/product_recommendation_page.dart';
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
  final List<String> validBodyTypes = [
  'Straight Frame',
  'V-Shape Build',
  'Round Body',
  'Fit & Toned',
  'Compact Build',
  'Slim Soft',
  'Balanced Shape',
];


  late final ImageLabeler _labeler;

  final List<Map<String, String>> bodyTypes = [
    {
      'label': 'Straight Frame',
      'image': 'assets/bodyType/body1.png',
      'desc' : 'Equal shoulders, waist, and hips.',
    },
    {
      'label': 'V-Shape Build',
      'image': 'assets/bodyType/body2.png',
      'desc' : 'Broad shoulders, narrow waistline below.',
    },
    {
      'label': 'Round Body',
      'image': 'assets/bodyType/body3.png',
      'desc' : 'Softer belly with wider torso.',
    },
    {
      'label': 'Fit & Toned',
      'image': 'assets/bodyType/body4.png',
      'desc' : 'Lean body with visible muscle.',
    },
    {
      'label': 'Compact Build',
      'image': 'assets/bodyType/body5.png',
      'desc' : 'Short, thick, strong-looking frame.',
    },
    {
      'label': 'Slim Soft',
      'image': 'assets/bodyType/body6.png',
      'desc' : 'Thin frame with less muscle tone.',
    },
    {
      'label': 'Balanced Shape',
      'image': 'assets/bodyType/body7.png',
      'desc' : 'Broad top, defined lower waist.',
    },
  ];

  

  final Map<String, List<String>> _bodyTypeOutfitSuggestions = {
    'Straight Frame': [
      'Tailored double-breasted blazer & straight trousers',
      'Bomber jacket over crew-neck tee & tapered chinos',
      'Vertical-stripe button-down & dark denim',
      'Fitted polo shirt with slim khakis',
      'Layered denim jacket & knit sweater',
      'Slim-fit turtleneck & tailored slacks',
      'Monochromatic navy tee & pants',
      'Lightweight parka & slim cargo pants',
      'Denim-on-denim jacket + jeans',
      'Henley shirt & suede loafers',
      'Oxford shirt with straight-cut pants',
      'Trench coat over crew-neck & chinos',
      'Structured peacoat & slim jeans',
      'Merino crewneck & tailored shorts',
      'Blazer + jeans + white sneakers',
    ],
    'V-Shape Build': [
      'Fitted v-neck tee & slim joggers',
      'Athletic-cut polo & tapered chinos',
      'Wool blazer with narrow lapels & slim pants',
      'Crewneck sweater & drop-shoulder coat',
      'Bomber jacket & slim cargo pants',
      'Henley shirt under denim jacket',
      'Muscle-fit tank & athletic track pants',
      'Structured peacoat & straight jeans',
      'Slim-fit hoodie & tapered sweats',
      'Denim jacket & slim khakis',
      'Leather biker jacket & fitted jeans',
      'Textured knit sweater & cords',
      'Lightweight windbreaker & joggers',
      'Tailored suit with narrow tie',
      'Puffer vest over long-sleeve tee',
    ],
    'Round Body': [
      'Vertical-stripe shirt & dark jeans',
      'Single-breasted blazer & V-neck tee',
      'Layered open cardigan & slim pants',
      'Longline bomber & straight chinos',
      'Unstructured blazer & crew-neck T',
      'Henley shirt & dark wash denim',
      'Monochrome dark outfit',
      'Lightweight trench & slim-cut trousers',
      'Textured sweater & vertical-pattern pants',
      'Denim jacket & black jeans',
      'V-neck sweater layered under coat',
      'Slim joggers & structured jacket',
      'Tailored overcoat & tapered pants',
      'Streamlined leather jacket & jeans',
      'Soft-weave cardigan & straight pants',
    ],
    'Fit & Toned': [
      'Fitted crew-neck tee & skinny jeans',
      'Muscle-fit tank & slim joggers',
      'Cropped denim jacket & tailored pants',
      'Slim-cut suit with narrow lapels',
      'Athleisure hoodie & technical joggers',
      'Henley shirt & stretch chinos',
      'Leather moto jacket & tapered jeans',
      'Bomber jacket & slim cargos',
      'Fitted polo & tailored shorts',
      'Lightweight windbreaker & joggers',
      'V-neck tee & ripped skinny denim',
      'Denim vest over tee & jeans',
      'Structured blazer & slim dress pants',
      'Athletic cut polo & track pants',
      'Layered open shirt & stretch jeans',
    ],
    'Compact Build': [
      'Button-down shirt & tapered chinos',
      'Short bomber jacket & slim jeans',
      'Structured blazer & straight trousers',
      'Crew-neck sweater & slim cords',
      'Denim jacket & fitted pants',
      'Fitted polo & tailored shorts',
      'Textured knit jumper & joggers',
      'Henley shirt & slim cargos',
      'Lightweight parka & skinny jeans',
      'Monochrome grey look',
      'Leather biker jacket & slim denim',
      'Tailored vest & tapered slacks',
      'Unstructured coat & straight chinos',
      'Merino crewneck & fitted jeans',
      'Slim-leg suit & casual sneakers',
    ],
    'Slim Soft': [
      'Layered lightweight jacket & hoodie',
      'Overshirt over tee & straight jeans',
      'Textured knit sweater & chinos',
      'Henley shirt layered with vest',
      'Denim jacket & relaxed-fit pants',
      'Crew-neck tee & slim joggers',
      'Soft wool blazer & straight slacks',
      'Patterned shirt & dark denim',
      'Light trench coat & slim chinos',
      'Bomber jacket & casual trousers',
      'Fitted vest over open shirt',
      'Cable-knit sweater & jeans',
      'Tailored cardigan & straight pants',
      'Monochrome beige outfit',
      'Unstructured overshirt & joggers',
    ],
    'Balanced Shape': [
      'Structured blazer & straight trousers',
      'Button-down shirt & slim chinos',
      'V-neck sweater layered under coat',
      'Denim jacket & dark wash jeans',
      'Crew-neck tee & tailored shorts',
      'Textured blazer & tapered pants',
      'Bomber jacket over tee & joggers',
      'Henley shirt & slim denim',
      'Lightweight parka & slim cargos',
      'Monochrome navy look',
      'Tailored overcoat & straight jeans',
      'Leather moto jacket & fitted pants',
      'Patterned shirt & solid trousers',
      'Merino wool crewneck & cords',
      'Unstructured coat & slim chinos',
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
      _trendingStyles = [...?_bodyTypeOutfitSuggestions[_bodyType], ..._trendingOutfits];
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
      // ignore: use_build_context_synchronously
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
    List<Map<String, dynamic>> recommendedList = [];
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => WardrobeRecommendationPage(items: recommendedList),
  ),
);

  }

  void _findSimilarProducts() {
    setState(() {
      _recommendedOutfits = [
        'Similar products from our partners',
        'Recommended brands',
        'Trending items matching your style'
      ];
    });
    List<Map<String, dynamic>> myProductList = [];
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ProductRecommendationPage(products: myProductList),
  ),
);

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
          // _buildTrendingStylesSection(),
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
        // ignore: deprecated_member_use
        Text('Recommended for $_bodyType body type:', style: TextStyle(color: Colors.white.withOpacity(0.8))),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _bodyTypeOutfitSuggestions[_bodyType]!.map((outfit) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text(outfit, style: TextStyle(color: AppColors.cardBackgroundColor)),
                  // ignore: deprecated_member_use
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  // ignore: deprecated_member_use
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
                      // ignore: deprecated_member_use
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

  // SliverToBoxAdapter _buildTrendingStylesSection() {
  //   return SliverToBoxAdapter(
  //     child: Padding(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text('Trending Styles for You',
  //               style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
  //           const SizedBox(height: 12),
  //           SizedBox(
  //             height: 220,
  //             child: ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               itemCount: _trendingStyles.length,
  //               itemBuilder: (context, index) => Container(
  //                 width: 160,
  //                 margin: const EdgeInsets.only(right: 16),
  //                 child: _buildTrendingStyleCard(_trendingStyles[index]),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
            // ignore: deprecated_member_use
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
          // ignore: deprecated_member_use
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
