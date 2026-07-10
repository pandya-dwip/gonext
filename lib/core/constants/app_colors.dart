import 'package:flutter/material.dart';

/// AppColors defines the visual design system palette from the GoNext Design System doc.
class AppColors {
  AppColors._();

  static bool isDark = false;

  // Core Brand Colors
  static Color get primary => _primary;
  static set primary(Color val) => _primary = val;
  static Color _primary = const Color(0xFF1B7A5B); // Emerald

  static Color get primaryDeep => _primaryDeep;
  static set primaryDeep(Color val) => _primaryDeep = val;
  static Color _primaryDeep = const Color(0xFF0F5E45); // Pressed states, shadow base

  static Color get secondary => _secondary;
  static set secondary(Color val) => _secondary = val;
  static Color _secondary = const Color(0xFF1E8A87); // Teal

  // Background and Surfaces
  static Color get background => isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF); // Pure White/Dark
  static Color get surface => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  static Color get surfaceFaint => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF6F8F7); // Subtle card/input contrasts
  static Color get cardSurface => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);

  // Text Colors
  static Color get textPrimary => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF222222); // Headlines, body
  static Color get textSecondary => isDark ? const Color(0xFFB0B3B2) : const Color(0xFF5B6360); // Captions, helper text
  static Color get textMuted => isDark ? const Color(0xFF6C7370) : const Color(0xFF8C9693); // Highly muted text

  // Borders & Dividers
  static Color get border => isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE7EAE8); // Hairline dividers, borders
  static Color get divider => isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE7EAE8);

  // Feedback/Semantic Colors
  static Color get success => const Color(0xFF3E8E5A); // Visited tags
  static Color get warning => const Color(0xFFC97A2B); // Budget warning tags
  static Color get error => const Color(0xFFC4574B); // Delete/Destructive actions

  // Primary & Secondary container tints (8-12% opacity over white/dark)
  static Color get primaryContainer => isDark ? const Color(0xFF1B2E28) : const Color(0xFFE8F2EE);
  static Color get secondaryContainer => isDark ? const Color(0xFF1B2E2E) : const Color(0xFFE8F3F3);

  // Gradient Colors
  static List<Color> get heroGradient => isDark
      ? const [Color(0x1F1B7A5B), Color(0x1F1E8A87)]
      : const [Color(0x141B7A5B), Color(0x141E8A87)];
}
