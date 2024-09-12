import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'image_gallery.dart';

/// The entry point of the application.
void main() {
  runApp(const MyApp());
}

/// Main application widget. Sets up localization and loads the [ImageGallery] widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), 
      ],
      home: const ImageGallery(), 
    );
  }
}
