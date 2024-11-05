import 'dart:io'; // For handling file

import 'package:firebase_storage/firebase_storage.dart'; // Firebase storage
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:path/path.dart'; // For file path handling

class ImageCapture extends StatefulWidget {
  final Function(String) onImageUploaded; // Callback to pass image URL

  ImageCapture({required this.onImageUploaded});

  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker

  // Function to pick image from camera
  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.camera); // Open camera
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  // Upload image to Firebase Storage and get the URL
  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    // Generate a unique file name
    String fileName = basename(_imageFile!.path);
    try {
      // Reference to Firebase Storage
      Reference storageReference =
          FirebaseStorage.instance.ref().child('SnapRecipe/$fileName');

      // Upload the image
      UploadTask uploadTask = storageReference.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Call the callback with the download URL
      widget.onImageUploaded(downloadUrl);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _imageFile != null
            ? Image.file(
                _imageFile!,
                height: 200, // Adjust the height of the image here
                width: double.infinity, // Image width stretches to container
                fit: BoxFit.cover, // To ensure the image fits within the bounds
              )
            : Text("No image selected."),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _pickImage, // Trigger the image picking function
          child: Text("Capture Image"),
        ),
      ],
    );
  }
}
