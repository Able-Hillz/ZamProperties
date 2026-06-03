import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'ZamProperties';
  static const String appVersion = '1.0.0';
  
  // Colors (Zambian inspired)
  static const Color primaryColor = Color(0xFF1B5E20); // Deep green
  static const Color secondaryColor = Color(0xFFF9A825); // Warm orange/gold
  static const Color accentColor = Color(0xFF1565C0); // Trust blue
  
  // Text Styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
  
  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double cardBorderRadius = 12.0;
}