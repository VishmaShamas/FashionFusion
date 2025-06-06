import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/foundation.dart';

class AddToWardrobeImagePicker extends StatefulWidget {
  const AddToWardrobeImagePicker({super.key});

  @override
  State<AddToWardrobeImagePicker> createState() =>
      _AddToWardrobeImagePickerState();
}

class _AddToWardrobeImagePickerState extends State<AddToWardrobeImagePicker> {
  String _selectedImagePath = '';

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      log('Picked file path: ${pickedFile.path}');
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    } else {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('No image selected')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 0.8;
    final double height = MediaQuery.of(context).size.height * 0.4;

    return Center(
      child: GestureDetector(
        onTap: () => _showImagePickerOptions(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400, width: 2),
                image:
                    _selectedImagePath.isEmpty
                        ? const DecorationImage(
                          image: AssetImage(
                            'assets/images/wardrobe_placeholder.png',
                          ),
                          fit: BoxFit.cover,
                        )
                        : DecorationImage(
                          image:
                              kIsWeb
                                  ? NetworkImage(_selectedImagePath)
                                  : FileImage(File(_selectedImagePath))
                                      as ImageProvider,
                          fit: BoxFit.cover,
                        ),
              ),
              child:
                  _selectedImagePath.isEmpty
                      ? const Center(
                        child: Text(
                          'Tap to add item to wardrobe',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      : null,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showImagePickerOptions(context),
              icon: const Icon(Icons.upload),
              label: const Text('Add/Change Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
