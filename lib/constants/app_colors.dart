import 'package:flutter/material.dart';

/// Centralized color constants for the Pockard app
/// All colors should be defined here and referenced throughout the app
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ========== PRIMARY THEME COLORS ==========

  /// Primary seed color (lighter red)
  static const Color primarySeed = Color(0xFFDE3932);

  /// Secondary seed color (darker red)
  static const Color secondarySeed = Color(0xFFB92218);

  /// Error color used across all themes
  static const Color error = Color(0xFFEF5350);

  // ========== DARK THEME SPECIFIC COLORS ==========

  /// Dark theme surface color (custom card color)
  static const Color darkSurface = Color(0xFF393E46);

  /// Dark theme background color
  static const Color darkBackground = Color(0xFF222831);

  // ========== AMOLED THEME SPECIFIC COLORS ==========

  /// AMOLED theme AppBar background (very dark gray instead of pure black)
  static const Color amoledAppBar = Color(0xFF1B1B1B);

  /// AMOLED theme card color (darker gray for better contrast)
  static const Color amoledCard = Color(0xFF1E1E1E);

  // ========== MATERIAL YOU THEME COLORS ==========

  /// Material You theme primary color (blue - more common system color)
  static const Color materialYouPrimary = Color(0xFF2196F3);

  /// Material You theme AppBar color (darker blue)
  static const Color materialYouAppBar = Color(0xFF1976D2);

  // ========== IMAGE GENERATOR COLORS ==========

  /// Predefined colors for image generation
  static const List<Color> imageGeneratorColors = [
    Color(0xFFE53E3E), // Red
    Color(0xFF3182CE), // Blue
    Color(0xFF38A169), // Green
    Color(0xFF805AD5), // Purple
    Color(0xFFD69E2E), // Orange
    Color(0xFF319795), // Teal
    Color(0xFFD53F8C), // Pink
    Color(0xFF4C51BF), // Indigo
    Color(0xFFD69E2E), // Amber
    Color(0xFF0BC5EA), // Cyan
    Color(0xFFDD6B20), // Deep Orange
    Color(0xFF0EA5E9), // Light Blue
  ];

  // ========== COMMON COLORS ==========

  /// Pure white
  static const Color white = Colors.white;

  /// Pure black
  static const Color black = Colors.black;

  /// Transparent
  static const Color transparent = Colors.transparent;

  // ========== UTILITY METHODS ==========

  /// Get contrast color (white or black) for a given background color
  static Color getContrastColor(Color backgroundColor) {
    // Calculate luminance
    final luminance = backgroundColor.computeLuminance();
    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? black : white;
  }

  /// Get a color with specified opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Success color for SnackBars and success states
  static Color get success => primarySeed; // Use theme primary for success

  /// Warning color
  static const Color warning = Color(0xFFFF9800);

  /// Info color
  static const Color info = Color(0xFF2196F3);
}
