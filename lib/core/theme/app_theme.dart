import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'app_typography.dart';

/// AppTheme implements the visual design system theme for GoNext.
/// It uses FlexColorScheme to initialize Material 3 base components
/// and copyWith overrides to match the custom widgets specification.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
      ),
      scaffoldBackground: AppColors.background,
      useMaterial3: true,
      useMaterial3ErrorColors: true,
      textTheme: AppTypography.textTheme,
      subThemesData: const FlexSubThemesData(
        // Card Styling: lg (24dp) radius, zero elevation
        cardRadius: AppSizes.r24,
        cardElevation: 0,

        // Button Styling: height 52dp, pill radius
        filledButtonRadius: AppSizes.rPill,
        elevatedButtonRadius: AppSizes.rPill,
        outlinedButtonRadius: AppSizes.rPill,
        textButtonRadius: AppSizes.rPill,
        buttonPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.p24,
          vertical: AppSizes.p16,
        ),

        // Chip Styling: pill radius
        chipRadius: AppSizes.rPill,
        chipSchemeColor: SchemeColor.primary,

        // Text Fields / Inputs: md (16dp) radius, filled faint surface
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: AppSizes.r16,
        inputDecoratorUnfocusedBorderIsColored: false,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorFillColor: AppColors.surfaceFaint,
        inputDecoratorIsFilled: true,

        // Dialog Styling: lg (24dp) radius
        dialogRadius: AppSizes.r24,
        dialogElevation: 4,

        // Bottom Nav (We override this in copyWith or custom widgets)
        navigationBarElevation: 0,
      ),
    ).copyWith(
      // Customize specific component themes directly for strict specs
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.cardSurface,
        margin: EdgeInsets.zero,
        shadowColor: Color(0x0A0F5E45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.r24)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1.0,
        space: 1.0,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
        ),
      ),
      // Set input decoration theme states manually for high fidelity
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceFaint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTypography.body.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}
