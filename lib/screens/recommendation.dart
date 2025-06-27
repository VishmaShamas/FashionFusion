import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_fusion/screens/wardrobe_recommendation_page.dart';
import 'package:fashion_fusion/widgets/ui/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class _PersonalizedRecommendationPageState
    extends State<PersonalizedRecommendationPage> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  double _scanPosition = 0;
  String? bodyType;
  String? userId;
  List<String> _recommendedOutfits = [];
  String _lastQuery = '';
  bool _showTextSearchOptions = false;

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
      'desc': 'Equal shoulders, waist, and hips.',
    },
    {
      'label': 'V-Shape Build',
      'image': 'assets/bodyType/body2.png',
      'desc': 'Broad shoulders, narrow waistline below.',
    },
    {
      'label': 'Round Body',
      'image': 'assets/bodyType/body3.png',
      'desc': 'Softer belly with wider torso.',
    },
    {
      'label': 'Fit & Toned',
      'image': 'assets/bodyType/body4.png',
      'desc': 'Lean body with visible muscle.',
    },
    {
      'label': 'Compact Build',
      'image': 'assets/bodyType/body5.png',
      'desc': 'Short, thick, strong-looking frame.',
    },
    {
      'label': 'Slim Soft',
      'image': 'assets/bodyType/body6.png',
      'desc': 'Thin frame with less muscle tone.',
    },
    {
      'label': 'Balanced Shape',
      'image': 'assets/bodyType/body7.png',
      'desc': 'Broad top, defined lower waist.',
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

  @override
  void initState() {
    super.initState();
    _fetchUserBodyType();
    _fetchUserId();

    final options = ImageLabelerOptions(confidenceThreshold: 0.6);
    _labeler = ImageLabeler(options: options);
  }

  void _fetchUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      userId = user.uid;
    });
  }

  void _fetchUserBodyType() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
          setState(() {
            bodyType = value.data()!['bodyType'];
          });
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

      setState(() {
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
    }
  }

  void _searchByDescription(String query) {
    setState(() {
      _selectedImage = null;
      _lastQuery = query;
      _showTextSearchOptions = true;
      _recommendedOutfits.clear(); // Hide random static suggestions
    });
  }

  void _searchTextWardrobe() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";
    final url = Uri.parse(
      'http://192.168.1.7:8000/search?query=${Uri.encodeComponent(_lastQuery)}&user_id=$userId&from_wardrobe=true',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<Map<String, dynamic>> recommendedList =
          List<Map<String, dynamic>>.from(decoded['results']);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WardrobeRecommendationPage(items: recommendedList),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Wardrobe search failed")));
    }
  }

  void _searchTextCatalog() async {
    final url = Uri.parse(
      'http://192.168.1.7:8000/search?query=${Uri.encodeComponent(_lastQuery)}&from_wardrobe=false',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<Map<String, dynamic>> productList = List<Map<String, dynamic>>.from(
        decoded['results'],
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductRecommendationPage(products: productList),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Catalog search failed")));
    }
  }

  void _findSimilarInWardrobe() async {
    if (_selectedImage == null) return;

    final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'http://192.168.1.7:8000/search-by-image',
      ).replace(queryParameters: {'user_id': userId, 'from_wardrobe': true}),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', _selectedImage!.path),
    );

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(responseData.body);
      List<Map<String, dynamic>> recommendedList =
          List<Map<String, dynamic>>.from(decoded['results']);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WardrobeRecommendationPage(items: recommendedList),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch from wardrobe.")));
    }
  }

  void _findSimilarProducts() async {
    if (_selectedImage == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'http://192.168.1.7:8000/search-by-image',
      ).replace(queryParameters: {'user_id': userId, 'from_wardrobe': false}),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', _selectedImage!.path),
    );

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(responseData.body);
      List<Map<String, dynamic>> myProductList =
          List<Map<String, dynamic>>.from(decoded['results']);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductRecommendationPage(products: myProductList),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch similar products.")),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body:
          bodyType == null
              ? const Center(child: CustomLoadingAnimation())
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: const Text(
                      'Style Assistant',
                      style: TextStyle(color: Colors.white),
                    ),
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
                  if (_showTextSearchOptions) _buildTextAnalysisSection(),
                  if (_recommendedOutfits.isNotEmpty)
                    _buildRecommendedOutfits(),
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
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {
              final text = _searchController.text.trim();
              if (text.isNotEmpty) _searchByDescription(text);
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white70),
            onPressed: (_pickAndAnalyzeImage),
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
            const Text(
              'Body Type: ',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              bodyType ?? '',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 12),
        // ignore: deprecated_member_use
        Text(
          'Recommended for $bodyType body type:',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 12),
        if (bodyType != null &&
            _bodyTypeOutfitSuggestions.containsKey(bodyType))
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _bodyTypeOutfitSuggestions[bodyType]!.map((outfit) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _searchByDescription(outfit),
                        child: Chip(
                          label: Text(
                            outfit,
                            style: TextStyle(
                              color: AppColors.cardBackgroundColor,
                            ),
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          )
        else
          const Text(
            'Loading outfit suggestions...',
            style: TextStyle(color: Colors.white70),
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
              const Text(
                'Analyzing image...',
                style: TextStyle(color: Colors.white70),
              ),
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

  SliverToBoxAdapter _buildTextAnalysisSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _searchTextWardrobe,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Find in Wardrobe'),
            ),
            ElevatedButton(
              onPressed: _searchTextCatalog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.samiDarkColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Shop Similar'),
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

  String _getOutfitImageUrl(String outfit) {
    return "https://source.unsplash.com/random/300x300/?men,fashion,${outfit.toLowerCase().replaceAll(' ', ',')}";
  }
}
