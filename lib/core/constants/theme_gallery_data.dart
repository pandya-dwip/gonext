import 'package:flutter/material.dart';

class ThemeSpec {
  final String name;
  final Color primary;
  final Color primaryDeep;
  final Color secondary;
  final String category; // 'Green Collection', 'Blue Collection', 'Purple Collection', 'Warm Collection', 'Neutral Collection', 'Dark Collection', 'Minimal Collection'

  const ThemeSpec({
    required this.name,
    required this.primary,
    required this.primaryDeep,
    required this.secondary,
    required this.category,
  });
}

const List<ThemeSpec> kThemeGallery = [
  // Green Collection
  ThemeSpec(name: 'Emerald', primary: Color(0xFF1B7A5B), primaryDeep: Color(0xFF0F5E45), secondary: Color(0xFF1E8A87), category: 'Green Collection'),
  ThemeSpec(name: 'Forest', primary: Color(0xFF228B22), primaryDeep: Color(0xFF1B5E20), secondary: Color(0xFF2E8B57), category: 'Green Collection'),
  ThemeSpec(name: 'Mint', primary: Color(0xFF3EB489), primaryDeep: Color(0xFF1B7A5B), secondary: Color(0xFF66CDAA), category: 'Green Collection'),
  ThemeSpec(name: 'Olive', primary: Color(0xFF808000), primaryDeep: Color(0xFF555500), secondary: Color(0xFF6B8E23), category: 'Green Collection'),
  ThemeSpec(name: 'Sage', primary: Color(0xFF87A96B), primaryDeep: Color(0xFF627F4B), secondary: Color(0xFFA9BA9D), category: 'Green Collection'),
  ThemeSpec(name: 'Pine', primary: Color(0xFF01796F), primaryDeep: Color(0xFF005850), secondary: Color(0xFF2E8B57), category: 'Green Collection'),
  ThemeSpec(name: 'Emerald Green', primary: Color(0xFF50C878), primaryDeep: Color(0xFF3A9856), secondary: Color(0xFF00A86B), category: 'Green Collection'),
  ThemeSpec(name: 'Teal Blue', primary: Color(0xFF008080), primaryDeep: Color(0xFF005E5E), secondary: Color(0xFF20B2AA), category: 'Green Collection'),

  // Blue Collection
  ThemeSpec(name: 'Ocean', primary: Color(0xFF0077BE), primaryDeep: Color(0xFF00568B), secondary: Color(0xFF00A86B), category: 'Blue Collection'),
  ThemeSpec(name: 'Teal', primary: Color(0xFF0D9488), primaryDeep: Color(0xFF0F766E), secondary: Color(0xFF14B8A6), category: 'Blue Collection'),
  ThemeSpec(name: 'Aqua', primary: Color(0xFF00D1D1), primaryDeep: Color(0xFF009B9B), secondary: Color(0xFF008B8B), category: 'Blue Collection'),
  ThemeSpec(name: 'Cyan', primary: Color(0xFF06B6D4), primaryDeep: Color(0xFF0891B2), secondary: Color(0xFF22D3EE), category: 'Blue Collection'),
  ThemeSpec(name: 'Royal Blue', primary: Color(0xFF4169E1), primaryDeep: Color(0xFF2A48C2), secondary: Color(0xFF1E90FF), category: 'Blue Collection'),
  ThemeSpec(name: 'Sapphire', primary: Color(0xFF0F52BA), primaryDeep: Color(0xFF0B3A85), secondary: Color(0xFF4169E1), category: 'Blue Collection'),
  ThemeSpec(name: 'Arctic', primary: Color(0xFF5F9EA0), primaryDeep: Color(0xFF467779), secondary: Color(0xFFADD8E6), category: 'Blue Collection'),
  ThemeSpec(name: 'Ice Blue', primary: Color(0xFF5A8FBA), primaryDeep: Color(0xFF3A698F), secondary: Color(0xFFE0FFFF), category: 'Blue Collection'),
  ThemeSpec(name: 'Sky', primary: Color(0xFF0EA5E9), primaryDeep: Color(0xFF0284C7), secondary: Color(0xFF38BDF8), category: 'Blue Collection'),
  ThemeSpec(name: 'Steel', primary: Color(0xFF4682B4), primaryDeep: Color(0xFF315F85), secondary: Color(0xFFB0C4DE), category: 'Blue Collection'),

  // Purple Collection
  ThemeSpec(name: 'Indigo', primary: Color(0xFF4B0082), primaryDeep: Color(0xFF3A0065), secondary: Color(0xFF6F00FF), category: 'Purple Collection'),
  ThemeSpec(name: 'Lavender', primary: Color(0xFF967BB6), primaryDeep: Color(0xFF755D96), secondary: Color(0xFFB57EDC), category: 'Purple Collection'),
  ThemeSpec(name: 'Purple', primary: Color(0xFF7C3AED), primaryDeep: Color(0xFF6D28D9), secondary: Color(0xFF8B5CF6), category: 'Purple Collection'),
  ThemeSpec(name: 'Violet', primary: Color(0xFF8F00FF), primaryDeep: Color(0xFF6A00BD), secondary: Color(0xFFD000FF), category: 'Purple Collection'),
  ThemeSpec(name: 'Magenta', primary: Color(0xFFD946EF), primaryDeep: Color(0xFFC026D3), secondary: Color(0xFFC084FC), category: 'Purple Collection'),
  ThemeSpec(name: 'Plum', primary: Color(0xFF8E4585), primaryDeep: Color(0xFF6B3064), secondary: Color(0xFFDDA0DD), category: 'Purple Collection'),
  ThemeSpec(name: 'Teaberry', primary: Color(0xFFE08D9C), primaryDeep: Color(0xFFB0626F), secondary: Color(0xFFF4C2C2), category: 'Purple Collection'),

  // Warm Collection
  ThemeSpec(name: 'Rose', primary: Color(0xFFF43F5E), primaryDeep: Color(0xFFE11D48), secondary: Color(0xFFFDA4AF), category: 'Warm Collection'),
  ThemeSpec(name: 'Coral', primary: Color(0xFFFF7F50), primaryDeep: Color(0xFFE05220), secondary: Color(0xFFFF6B6B), category: 'Warm Collection'),
  ThemeSpec(name: 'Crimson', primary: Color(0xFFDC143C), primaryDeep: Color(0xFFB01030), secondary: Color(0xFFFF2400), category: 'Warm Collection'),
  ThemeSpec(name: 'Sunset', primary: Color(0xFFF97316), primaryDeep: Color(0xFFC2410C), secondary: Color(0xFFF59E0B), category: 'Warm Collection'),
  ThemeSpec(name: 'Orange', primary: Color(0xFFEA580C), primaryDeep: Color(0xFFC2410C), secondary: Color(0xFFF97316), category: 'Warm Collection'),
  ThemeSpec(name: 'Amber', primary: Color(0xFFD97706), primaryDeep: Color(0xFFB45309), secondary: Color(0xFFF59E0B), category: 'Warm Collection'),
  ThemeSpec(name: 'Gold', primary: Color(0xFFDAA520), primaryDeep: Color(0xFFB8860B), secondary: Color(0xFFFFD700), category: 'Warm Collection'),
  ThemeSpec(name: 'Lemon', primary: Color(0xFFEAB308), primaryDeep: Color(0xFFCA8A04), secondary: Color(0xFFFACC15), category: 'Warm Collection'),
  ThemeSpec(name: 'Peach', primary: Color(0xFFF2A478), primaryDeep: Color(0xFFC7784D), secondary: Color(0xFFFFDAB9), category: 'Warm Collection'),
  ThemeSpec(name: 'Cherry', primary: Color(0xFFD2143A), primaryDeep: Color(0xFF900F29), secondary: Color(0xFFFF4D6D), category: 'Warm Collection'),
  ThemeSpec(name: 'Ruby', primary: Color(0xFFE0115F), primaryDeep: Color(0xFF9A0F41), secondary: Color(0xFFFF4081), category: 'Warm Collection'),
  ThemeSpec(name: 'Clay', primary: Color(0xFFC2410C), primaryDeep: Color(0xFF9A3412), secondary: Color(0xFFD97706), category: 'Warm Collection'),
  ThemeSpec(name: 'Pumpkin', primary: Color(0xFFFF7518), primaryDeep: Color(0xFFD0500F), secondary: Color(0xFFFF9F1C), category: 'Warm Collection'),
  ThemeSpec(name: 'Bronze', primary: Color(0xFFCD7F32), primaryDeep: Color(0xFF9B5E20), secondary: Color(0xFFA87C43), category: 'Warm Collection'),
  ThemeSpec(name: 'Copper', primary: Color(0xFFB87333), primaryDeep: Color(0xFF8F5422), secondary: Color(0xFFD27D2D), category: 'Warm Collection'),
  ThemeSpec(name: 'Chocolate', primary: Color(0xFFD2691E), primaryDeep: Color(0xFF8B4513), secondary: Color(0xFFA0522D), category: 'Warm Collection'),
  ThemeSpec(name: 'Coffee', primary: Color(0xFF6F4E37), primaryDeep: Color(0xFF513827), secondary: Color(0xFF8C6239), category: 'Warm Collection'),
  ThemeSpec(name: 'Brass', primary: Color(0xFFC3A650), primaryDeep: Color(0xFF9E843A), secondary: Color(0xFFE5C158), category: 'Warm Collection'),

  // Neutral Collection
  ThemeSpec(name: 'Slate', primary: Color(0xFF64748B), primaryDeep: Color(0xFF475569), secondary: Color(0xFF334155), category: 'Neutral Collection'),
  ThemeSpec(name: 'Sand', primary: Color(0xFFC2B280), primaryDeep: Color(0xFF968A60), secondary: Color(0xFFE1C699), category: 'Neutral Collection'),

  // Dark Collection
  ThemeSpec(name: 'Navy', primary: Color(0xFF1E3A8A), primaryDeep: Color(0xFF1E293B), secondary: Color(0xFF3B82F6), category: 'Dark Collection'),
  ThemeSpec(name: 'Midnight', primary: Color(0xFF1E1E2C), primaryDeep: Color(0xFF11111B), secondary: Color(0xFF3F3F5C), category: 'Dark Collection'),

  // Minimal Collection
  ThemeSpec(name: 'Graphite', primary: Color(0xFF4B4F54), primaryDeep: Color(0xFF32363A), secondary: Color(0xFF6C7177), category: 'Minimal Collection'),
  ThemeSpec(name: 'Monochrome', primary: Color(0xFF222222), primaryDeep: Color(0xFF000000), secondary: Color(0xFF7F7F7F), category: 'Minimal Collection'),
  ThemeSpec(name: 'Charcoal', primary: Color(0xFF36454F), primaryDeep: Color(0xFF253037), secondary: Color(0xFF5F7582), category: 'Minimal Collection'),
];
