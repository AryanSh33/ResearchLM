import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'ResearchLM';
  static const String appDescription = 'AI-Powered Literature Survey Generator';

  // API Configuration
  static const String apiBaseUrl = 'YOUR_API_BASE_URL';
  static const String apiKey = 'YOUR_API_KEY';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';

  // Theme
  static const Color primaryColor = Color(0xFF10A37F);
  static const Color secondaryColor = Color(0xFF1A73E8);

  // Layout
  static const double sidebarWidth = 280;
  static const double mobileBreakpoint = 768;

  // Timing
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
}