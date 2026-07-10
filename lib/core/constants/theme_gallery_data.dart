import 'package:flutter/material.dart';

class ThemeSpec {
  final String name;
  final Color primary;
  final Color primaryDeep;
  final Color secondary;

  const ThemeSpec({
    required this.name,
    required this.primary,
    required this.primaryDeep,
    required this.secondary,
  });
}

const List<ThemeSpec> kThemeGallery = [
  ThemeSpec(name: 'Emerald', primary: Color(0xFF1B7A5B), primaryDeep: Color(0xFF0F5E45), secondary: Color(0xFF1E8A87)),
  ThemeSpec(name: 'Forest', primary: Color(0xFF228B22), primaryDeep: Color(0xFF1B5E20), secondary: Color(0xFF2E8B57)),
  ThemeSpec(name: 'Mint', primary: Color(0xFF3EB489), primaryDeep: Color(0xFF1B7A5B), secondary: Color(0xFF66CDAA)),
  ThemeSpec(name: 'Ocean', primary: Color(0xFF0077BE), primaryDeep: Color(0xFF00568B), secondary: Color(0xFF00A86B)),
  ThemeSpec(name: 'Teal', primary: Color(0xFF0D9488), primaryDeep: Color(0xFF0F766E), secondary: Color(0xFF0F766E)),
  ThemeSpec(name: 'Aqua', primary: Color(0xFF00D1D1), primaryDeep: Color(0xFF009B9B), secondary: Color(0xFF008B8B)),
  ThemeSpec(name: 'Cyan', primary: Color(0xFF06B6D4), primaryDeep: Color(0xFF0891B2), secondary: Color(0xFF0891B2)),
  ThemeSpec(name: 'Royal Blue', primary: Color(0xFF4169E1), primaryDeep: Color(0xFF2A48C2), secondary: Color(0xFF1E90FF)),
  ThemeSpec(name: 'Navy', primary: Color(0xFF1A365D), primaryDeep: Color(0xFF0F2537), secondary: Color(0xFF4682B4)),
  ThemeSpec(name: 'Sapphire', primary: Color(0xFF0F52BA), primaryDeep: Color(0xFF0B3A85), secondary: Color(0xFF4169E1)),
  ThemeSpec(name: 'Indigo', primary: Color(0xFF4B0082), primaryDeep: Color(0xFF3A0065), secondary: Color(0xFF6F00FF)),
  ThemeSpec(name: 'Lavender', primary: Color(0xFF967BB6), primaryDeep: Color(0xFF755D96), secondary: Color(0xFFB57EDC)),
  ThemeSpec(name: 'Purple', primary: Color(0xFF7C3AED), primaryDeep: Color(0xFF6D28D9), secondary: Color(0xFF8B5CF6)),
  ThemeSpec(name: 'Violet', primary: Color(0xFF8F00FF), primaryDeep: Color(0xFF6A00BD), secondary: Color(0xFFD000FF)),
  ThemeSpec(name: 'Magenta', primary: Color(0xFFD946EF), primaryDeep: Color(0xFFC026D3), secondary: Color(0xFFC084FC)),
  ThemeSpec(name: 'Rose', primary: Color(0xFFF43F5E), primaryDeep: Color(0xFFE11D48), secondary: Color(0xFFFDA4AF)),
  ThemeSpec(name: 'Coral', primary: Color(0xFFFF7F50), primaryDeep: Color(0xFFE05220), secondary: Color(0xFFFF6B6B)),
  ThemeSpec(name: 'Crimson', primary: Color(0xFFDC143C), primaryDeep: Color(0xFFB01030), secondary: Color(0xFFFF2400)),
  ThemeSpec(name: 'Sunset', primary: Color(0xFFF97316), primaryDeep: Color(0xFFC2410C), secondary: Color(0xFFF59E0B)),
  ThemeSpec(name: 'Orange', primary: Color(0xFFEA580C), primaryDeep: Color(0xFFC2410C), secondary: Color(0xFFF97316)),
  ThemeSpec(name: 'Amber', primary: Color(0xFFD97706), primaryDeep: Color(0xFFB45309), secondary: Color(0xFFF59E0B)),
  ThemeSpec(name: 'Gold', primary: Color(0xFFDAA520), primaryDeep: Color(0xFFB8860B), secondary: Color(0xFFFFD700)),
  ThemeSpec(name: 'Lemon', primary: Color(0xFFEAB308), primaryDeep: Color(0xFFCA8A04), secondary: Color(0xFFFACC15)),
  ThemeSpec(name: 'Lime', primary: Color(0xFF84CC16), primaryDeep: Color(0xFF65A30D), secondary: Color(0xFF65A30D)),
  ThemeSpec(name: 'Olive', primary: Color(0xFF808000), primaryDeep: Color(0xFF555500), secondary: Color(0xFF6B8E23)),
  ThemeSpec(name: 'Chocolate', primary: Color(0xFFD2691E), primaryDeep: Color(0xFF8B4513), secondary: Color(0xFFA0522D)),
  ThemeSpec(name: 'Coffee', primary: Color(0xFF6F4E37), primaryDeep: Color(0xFF513827), secondary: Color(0xFF8C6239)),
  ThemeSpec(name: 'Slate', primary: Color(0xFF64748B), primaryDeep: Color(0xFF475569), secondary: Color(0xFF334155)),
  ThemeSpec(name: 'Graphite', primary: Color(0xFF4B4F54), primaryDeep: Color(0xFF32363A), secondary: Color(0xFF6C7177)),
  ThemeSpec(name: 'Steel', primary: Color(0xFF4682B4), primaryDeep: Color(0xFF315F85), secondary: Color(0xFFB0C4DE)),
  ThemeSpec(name: 'Arctic', primary: Color(0xFF5F9EA0), primaryDeep: Color(0xFF467779), secondary: Color(0xFFADD8E6)),
  ThemeSpec(name: 'Ice Blue', primary: Color(0xFF5A8FBA), primaryDeep: Color(0xFF3A698F), secondary: Color(0xFFE0FFFF)),
  ThemeSpec(name: 'Sky', primary: Color(0xFF0EA5E9), primaryDeep: Color(0xFF0284C7), secondary: Color(0xFF38BDF8)),
  ThemeSpec(name: 'Peach', primary: Color(0xFFF2A478), primaryDeep: Color(0xFFC7784D), secondary: Color(0xFFFFDAB9)),
  ThemeSpec(name: 'Cherry', primary: Color(0xFFD2143A), primaryDeep: Color(0xFF900F29), secondary: Color(0xFFFF4D6D)),
  ThemeSpec(name: 'Ruby', primary: Color(0xFFE0115F), primaryDeep: Color(0xFF9A0F41), secondary: Color(0xFFFF4081)),
  ThemeSpec(name: 'Sand', primary: Color(0xFFC2B280), primaryDeep: Color(0xFF968A60), secondary: Color(0xFFE1C699)),
  ThemeSpec(name: 'Clay', primary: Color(0xFFC2410C), primaryDeep: Color(0xFF9A3412), secondary: Color(0xFFD97706)),
  ThemeSpec(name: 'Midnight', primary: Color(0xFF1E1E2C), primaryDeep: Color(0xFF11111B), secondary: Color(0xFF3F3F5C)),
  ThemeSpec(name: 'Monochrome', primary: Color(0xFF222222), primaryDeep: Color(0xFF000000), secondary: Color(0xFF7F7F7F)),
  ThemeSpec(name: 'Plum', primary: Color(0xFF8E4585), primaryDeep: Color(0xFF6B3064), secondary: Color(0xFFDDA0DD)),
  ThemeSpec(name: 'Teaberry', primary: Color(0xFFE08D9C), primaryDeep: Color(0xFFB0626F), secondary: Color(0xFFF4C2C2)),
  ThemeSpec(name: 'Emerald Green', primary: Color(0xFF50C878), primaryDeep: Color(0xFF3A9856), secondary: Color(0xFF00A86B)),
  ThemeSpec(name: 'Brass', primary: Color(0xFFC3A650), primaryDeep: Color(0xFF9E843A), secondary: Color(0xFFE5C158)),
  ThemeSpec(name: 'Sage', primary: Color(0xFF87A96B), primaryDeep: Color(0xFF627F4B), secondary: Color(0xFFA9BA9D)),
  ThemeSpec(name: 'Pine', primary: Color(0xFF01796F), primaryDeep: Color(0xFF005850), secondary: Color(0xFF2E8B57)),
  ThemeSpec(name: 'Pumpkin', primary: Color(0xFFFF7518), primaryDeep: Color(0xFFD0500F), secondary: Color(0xFFFF9F1C)),
  ThemeSpec(name: 'Bronze', primary: Color(0xFFCD7F32), primaryDeep: Color(0xFF9B5E20), secondary: Color(0xFFA87C43)),
  ThemeSpec(name: 'Teal Blue', primary: Color(0xFF008080), primaryDeep: Color(0xFF005E5E), secondary: Color(0xFF20B2AA)),
  ThemeSpec(name: 'Copper', primary: Color(0xFFB87333), primaryDeep: Color(0xFF8F5422), secondary: Color(0xFFD27D2D)),
  ThemeSpec(name: 'Charcoal', primary: Color(0xFF36454F), primaryDeep: Color(0xFF253037), secondary: Color(0xFF5F7582)),
];
