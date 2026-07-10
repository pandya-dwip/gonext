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
  static Color get background => isDark ? const Color(0xFF0D0F0E) : const Color(0xFFFFFFFF); // Deep premium dark background
  static Color get surface => isDark ? const Color(0xFF141715) : const Color(0xFFFFFFFF); // M3 Surface
  static Color get surfaceFaint => isDark ? const Color(0xFF1E2220) : const Color(0xFFF4F6F5); // Text fields and subtle tiles
  static Color get cardSurface => isDark ? const Color(0xFF141715) : const Color(0xFFFFFFFF); // Cards surface

  // Text Colors
  static Color get textPrimary => isDark ? const Color(0xFFF5F7F6) : const Color(0xFF1E2220); // High contrast text
  static Color get textSecondary => isDark ? const Color(0xFF9CA5A1) : const Color(0xFF5B6360); // Neutral variant text
  static Color get textMuted => isDark ? const Color(0xFF6E7874) : const Color(0xFF8C9693); // Low contrast text

  // Borders & Dividers
  static Color get border => isDark ? const Color(0xFF232826) : const Color(0xFFE7EAE8);
  static Color get divider => isDark ? const Color(0xFF232826) : const Color(0xFFE7EAE8);

  // Feedback/Semantic Colors
  static Color get success => const Color(0xFF3E8E5A); // Visited tags
  static Color get warning => const Color(0xFFC97A2B); // Budget warning tags
  static Color get error => const Color(0xFFC4574B); // Delete/Destructive actions

  // Primary & Secondary container tints (dynamic to chosen primary/secondary)
  static Color get primaryContainer => isDark ? _primary.withValues(alpha: 0.15) : _primary.withValues(alpha: 0.08);
  static Color get secondaryContainer => isDark ? _secondary.withValues(alpha: 0.15) : _secondary.withValues(alpha: 0.08);

  // Gradient Colors
  static List<Color> get heroGradient => isDark
      ? [const Color(0x221B7A5B), const Color(0x221E8A87)]
      : [const Color(0x141B7A5B), const Color(0x141E8A87)];
}
