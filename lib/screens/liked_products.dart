import 'package:flutter/material.dart';

class LikedProducts extends StatefulWidget {
  const LikedProducts({super.key});

  @override
  State<LikedProducts> createState() => _LikedProductsState();
}

class _LikedProductsState extends State<LikedProducts> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text('Liked Products'));
  }
}
