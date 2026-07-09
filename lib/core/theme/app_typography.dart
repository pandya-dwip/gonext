import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// AppTypography defines the pairing of Outfit (for headings) and Inter (for body).
class AppTypography {
  AppTypography._();

  // Typography Scales
  static const double sizeDisplay = 34.0;
  static const double sizeTitleLarge = 28.0;
  static const double sizeTitle = 22.0;
  static const double sizeSubtitle = 17.0;
  static const double sizeBody = 15.0;
  static const double sizeCaption = 13.0;
  static const double sizeOverline = 12.0;

  // Outfit Font for display and titles
  static TextStyle get display => GoogleFonts.outfit(
        fontSize: sizeDisplay,
        fontWeight: FontWeight.bold,
        height: 41.0 / sizeDisplay, // ~1.20
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: sizeTitleLarge,
        fontWeight: FontWeight.w600, // SemiBold
        height: 34.0 / sizeTitleLarge, // ~1.21
        color: AppColors.textPrimary,
      );

  static TextStyle get title => GoogleFonts.outfit(
        fontSize: sizeTitle,
        fontWeight: FontWeight.w600, // SemiBold
        height: 28.0 / sizeTitle, // ~1.27
        color: AppColors.textPrimary,
      );

  // Inter Font for bodies and captions
  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: sizeSubtitle,
        fontWeight: FontWeight.w500, // Medium
        height: 24.0 / sizeSubtitle, // ~1.41
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: sizeBody,
        fontWeight: FontWeight.w400, // Regular
        height: 22.0 / sizeBody, // ~1.46
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyEmphasis => GoogleFonts.inter(
        fontSize: sizeBody,
        fontWeight: FontWeight.w500, // Medium
        height: 22.0 / sizeBody, // ~1.46
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: sizeCaption,
        fontWeight: FontWeight.w400, // Regular
        height: 18.0 / sizeCaption, // ~1.38
        color: AppColors.textSecondary,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: sizeOverline,
        fontWeight: FontWeight.w600, // SemiBold
        height: 16.0 / sizeOverline, // ~1.33
        letterSpacing: 0.6,
        color: AppColors.textSecondary,
      ).copyWith(
        fontFeatures: const [FontFeature.enable('case')],
      );

  /// Compiles unified [TextTheme] mapping to Flutter ThemeData typography slots
  static TextTheme get textTheme => TextTheme(
        displayLarge: display,
        displayMedium: display,
        displaySmall: display,
        headlineLarge: titleLarge,
        headlineMedium: title,
        headlineSmall: subtitle,
        titleLarge: titleLarge,
        titleMedium: title,
        titleSmall: subtitle,
        bodyLarge: bodyEmphasis,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: bodyEmphasis,
        labelMedium: caption,
        labelSmall: overline,
      );
}
