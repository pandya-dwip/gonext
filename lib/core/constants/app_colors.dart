import 'package:flutter/material.dart';

/// AppColors defines the visual design system palette from the GoNext Design System doc.
class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color primary = Color(0xFF1B7A5B); // Emerald
  static const Color primaryDeep = Color(0xFF0F5E45); // Pressed states, shadow base
  static const Color secondary = Color(0xFF1E8A87); // Teal

  // Background and Surfaces
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceFaint = Color(0xFFF6F8F7); // Subtle card/input contrasts
  static const Color cardSurface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF222222); // Headlines, body
  static const Color textSecondary = Color(0xFF5B6360); // Captions, helper text
  static const Color textMuted = Color(0xFF8C9693); // Highly muted text

  // Borders & Dividers
  static const Color border = Color(0xFFE7EAE8); // Hairline dividers, borders
  static const Color divider = Color(0xFFE7EAE8);

  // Feedback/Semantic Colors
  static const Color success = Color(0xFF3E8E5A); // Visited tags
  static const Color warning = Color(0xFFC97A2B); // Budget warning tags
  static const Color error = Color(0xFFC4574B); // Delete/Destructive actions

  // Primary & Secondary container tints (8-12% opacity over white)
  static const Color primaryContainer = Color(0xFFE8F2EE);
  static const Color secondaryContainer = Color(0xFFE8F3F3);

  // Gradient Colors
  static const List<Color> heroGradient = [
    Color(0x141B7A5B), // 8% opacity Emerald
    Color(0x141E8A87), // 8% opacity Teal
  ];
}
