import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerField extends StatelessWidget {
  final String? imagePath;
  final Function(String) onImagePicked;

  const ImagePickerField({this.imagePath, required this.onImagePicked, Key? key}) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImagePicked(pickedFile.path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imagePath != null)
          Image.file(
            File(imagePath!),
            height: 150,
            fit: BoxFit.cover,
          ),
        ElevatedButton(
          onPressed: () => _pickImage(context),
          child: const Text('Select Image'),
        ),
      ],
    );
  }
}
