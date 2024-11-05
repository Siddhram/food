import 'package:ap/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/homepage.dart';
import 'screens/image_capture.dart';
import 'screens/landing.dart';
import 'screens/login.dart';
import 'screens/recipe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapRecipe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/landing', // Set initial route to Landing Page
      routes: {
        '/landing': (context) => LandingScreen(), // Landing page route
        '/login': (context) => LoginScreen(), // Login page route
        '/homepage': (context) => HomePage(),
        '/image_capture': (context) => ImageCapture(
              onImageUploaded: (url) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipePage(),
                  ),
                );
              },
            ), // Pass URL to Recipe Page upon upload
        '/recipe': (context) => RecipePage(), // Recipe page route
      },
      home: LandingScreen(), // Start with Landing Screen
    );
  }
}
