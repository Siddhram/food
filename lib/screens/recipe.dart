import 'dart:convert'; // To encode/decode JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _imageUrl;
  String? _responseText; // Variable to store the response

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImageToFirebase();
    }
  }

  Future<void> _sendImageDescriptionRequest() async {
    final url = 'https://jsgemiintegration.onrender.com/image';
    final body = jsonEncode({
      "prompt": "describe the image",
      "imageUrl": _imageUrl ?? "https://example.com/default_image.png",
      "sessionId": "siddharamsutar23@gmail.com",
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          _responseText = jsonDecode(response.body)['response'];
        });
      } else {
        setState(() {
          _responseText = "Failed to fetch response: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _responseText = "Error occurred: $e";
      });
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_image != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('ingredients/${DateTime.now().toIso8601String()}.jpg');

      try {
        await storageRef.putFile(_image!);
        final url = await storageRef.getDownloadURL();
        setState(() {
          _imageUrl = url; // Store the image URL
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "What is in your kitchen?",
          style: TextStyle(
            color: Colors.black,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera Icon
            Center(
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 60, color: Colors.blue),
                onPressed: () => _showImageSourceDialog(context),
              ),
            ),
            SizedBox(height: 20),

            // Input Box
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter a description...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              onSubmitted: (value) {
                _sendImageDescriptionRequest();
              },
            ),
            SizedBox(height: 20),

            // Display uploaded image
            if (_imageUrl != null) ...[
              Center(
                child: Image.network(
                  _imageUrl!,
                  height: 200, // You can adjust the height as needed
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
            ],

            // Display response
            if (_responseText != null) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _responseText!,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
