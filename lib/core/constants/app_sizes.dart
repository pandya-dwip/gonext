import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppSizes defines the strict spacing scale, radius scale, and elevation shadow levels
/// based on the GoNext Design System guidelines. It also preserves intermediate helper
/// dimensions to maintain layout compilation.
class AppSizes {
  AppSizes._();

  // Spacing Scale (4pt base)
  static const double p2 = 2.0;   // extra small helper
  static const double p4 = 4.0;   // xs: icon-to-label, chip padding
  static const double p8 = 8.0;   // sm: between related elements
  static const double p12 = 12.0; // helper spacing
  static const double p16 = 16.0; // md: card padding, screen horizontal margin
  static const double p20 = 20.0; // helper spacing
  static const double p24 = 24.0; // lg: between components in a section
  static const double p32 = 32.0; // xl: between major sections
  static const double p40 = 40.0; // helper spacing
  static const double p48 = 48.0; // xxl: hero section padding, top breathing room
  static const double p64 = 64.0; // xxxl: empty-state centering offset

  // Reusable Sizedbox Gaps
  static const SizedBox gapW4 = SizedBox(width: p4);
  static const SizedBox gapW8 = SizedBox(width: p8);
  static const SizedBox gapW12 = SizedBox(width: p12);
  static const SizedBox gapW16 = SizedBox(width: p16);
  static const SizedBox gapW24 = SizedBox(width: p24);
  static const SizedBox gapW32 = SizedBox(width: p32);

  static const SizedBox gapH2 = SizedBox(height: p2);
  static const SizedBox gapH4 = SizedBox(height: p4);
  static const SizedBox gapH8 = SizedBox(height: p8);
  static const SizedBox gapH12 = SizedBox(height: p12);
  static const SizedBox gapH16 = SizedBox(height: p16);
  static const SizedBox gapH20 = SizedBox(height: p20);
  static const SizedBox gapH24 = SizedBox(height: p24);
  static const SizedBox gapH32 = SizedBox(height: p32);
  static const SizedBox gapH48 = SizedBox(height: p48);
  static const SizedBox gapH64 = SizedBox(height: p64);

  // Radius Scale
  static const double r4 = 4.0;
  static const double r8 = 8.0;     // sm: chips, badges, small buttons
  static const double r12 = 12.0;
  static const double r16 = 16.0;   // md: inputs, standard cards
  static const double r20 = 20.0;
  static const double r24 = 24.0;   // lg: hero cards, bottom sheets, dialogs
  static const double rPill = 999.0; // pill: FAB, filter chips, search bar

  static const BorderRadius borderRadiusCircular4 = BorderRadius.all(Radius.circular(r4));
  static const BorderRadius borderRadiusCircular8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius borderRadiusCircular12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius borderRadiusCircular16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius borderRadiusCircular20 = BorderRadius.all(Radius.circular(r20));
  static const BorderRadius borderRadiusCircular24 = BorderRadius.all(Radius.circular(r24));
  static const BorderRadius borderRadiusCircularPill = BorderRadius.all(Radius.circular(rPill));

  // Icon Sizing Scale
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s28 = 28.0; // Nav bar default
  static const double s32 = 32.0;
  static const double s48 = 48.0;

  // Custom Elevation & Shadow Levels (Using Emerald Deep #0F5E45 at low opacities)
  static const List<BoxShadow> _shadowLevel1Light = [
    BoxShadow(
      color: Color(0x0A0F5E45), // ~4% opacity of #0F5E45
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000), // ~3% opacity of black
      offset: Offset(0, 1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> _shadowLevel1Dark = [
    BoxShadow(
      color: Color(0x3D000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get shadowLevel1 => AppColors.isDark ? _shadowLevel1Dark : _shadowLevel1Light;

  static const List<BoxShadow> _shadowLevel2Light = [
    BoxShadow(
      color: Color(0x140F5E45), // ~8% opacity of #0F5E45
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> _shadowLevel2Dark = [
    BoxShadow(
      color: Color(0x52000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get shadowLevel2 => AppColors.isDark ? _shadowLevel2Dark : _shadowLevel2Light;

  static const List<BoxShadow> _shadowLevel3Light = [
    BoxShadow(
      color: Color(0x240F5E45), // ~14% opacity of #0F5E45
      offset: Offset(0, 12),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> _shadowLevel3Dark = [
    BoxShadow(
      color: Color(0x66000000),
      offset: Offset(0, 12),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get shadowLevel3 => AppColors.isDark ? _shadowLevel3Dark : _shadowLevel3Light;

  // Alias for backward compatibility
  static List<BoxShadow> get softShadow => shadowLevel1;
}
