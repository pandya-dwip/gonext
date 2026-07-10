import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/theme_gallery_data.dart';

/// Notifier to manage Theme Mode state ('light', 'dark', 'system')
class ThemeModeNotifier extends Notifier<ThemeMode> {
  late final Box _box;

  @override
  ThemeMode build() {
    _box = Hive.box('settings_box');
    final String saved = _box.get('themeMode', defaultValue: 'system') as String;
    return _parseThemeMode(saved);
  }

  ThemeMode _parseThemeMode(String val) {
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    String val = 'system';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.dark) val = 'dark';
    await _box.put('themeMode', val);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Notifier to manage Accent Color highlights
class AccentColorNotifier extends Notifier<String> {
  late final Box _box;

  @override
  String build() {
    _box = Hive.box('settings_box');
    final String saved = _box.get('accentColor', defaultValue: 'Emerald') as String;
    // Apply colors to AppColors class in memory
    _applyAccentColor(saved);
    return saved;
  }

  Future<void> setAccentColor(String colorName) async {
    state = colorName;
    _applyAccentColor(colorName);
    await _box.put('accentColor', colorName);
  }

  void _applyAccentColor(String colorName) {
    final match = kThemeGallery.firstWhere(
      (spec) => spec.name.toLowerCase() == colorName.toLowerCase(),
      orElse: () => kThemeGallery.first,
    );
    AppColors.primary = match.primary;
    AppColors.primaryDeep = match.primaryDeep;
    AppColors.secondary = match.secondary;
  }
}

final accentColorProvider = NotifierProvider<AccentColorNotifier, String>(AccentColorNotifier.new);
