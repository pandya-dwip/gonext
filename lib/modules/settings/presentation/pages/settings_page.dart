import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../places/data/models/place_model.dart';
import '../../../places/presentation/providers/place_provider.dart';
import '../../../../core/constants/demo_data.dart';
import '../providers/settings_provider.dart';
import '../../../../shared/components/gn_logo.dart';

/// SettingsPage provides backup/restore features, dark mode toggles,
/// theme gallery page navigation, and demo data loaders.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _showSuccessDialog(BuildContext context, String title, String desc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Text(title, style: AppTypography.title),
          ],
        ),
        content: Text(desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String desc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.error_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            Text(title, style: AppTypography.title),
          ],
        ),
        content: Text(desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    try {
      final places = ref.read(placesListProvider).value ?? [];
      final settingsBox = Hive.box('settings_box');
      final Map<String, dynamic> backupMap = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'places': places.map((p) => p.toJson()).toList(),
        'settings': {
          'themeMode': settingsBox.get('themeMode', defaultValue: 'system'),
          'accentColor': settingsBox.get('accentColor', defaultValue: 'emerald'),
        }
      };
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupMap);
      
      // Let user choose save directory
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) {
        // Fallback to documents directory if cancelled
        final documentsDir = await getApplicationDocumentsDirectory();
        directoryPath = documentsDir.path;
      }
      
      final filePath = '$directoryPath/gonext_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      try {
        final file = File(filePath);
        await file.writeAsString(jsonString);
        _showSuccessDialog(
          context,
          'Backup Successful',
          'Your GoNext backup file has been saved to:\n\n$filePath',
        );
      } catch (_) {
        // Fallback to safe application documents directory if selected folder picker lacks direct write permissions
        final documentsDir = await getApplicationDocumentsDirectory();
        final fallbackPath = '${documentsDir.path}/gonext_backup_${DateTime.now().millisecondsSinceEpoch}.json';
        final file = File(fallbackPath);
        await file.writeAsString(jsonString);
        _showSuccessDialog(
          context,
          'Backup Successful',
          'Saved to application directory due to folder write restrictions:\n\n$fallbackPath',
        );
      }
    } catch (e) {
      _showErrorDialog(context, 'Backup Failed', 'An error occurred during data backup: $e');
    }
  }

  Future<void> _restoreData(BuildContext context, WidgetRef ref) async {
    try {
      // Pick file
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) {
        return; // Cancelled
      }
      
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> backupMap = json.decode(content) as Map<String, dynamic>;
      
      // Validate
      if (!backupMap.containsKey('places') || backupMap['places'] is! List) {
        throw const FormatException('Invalid backup file structure.');
      }
      
      final list = backupMap['places'] as List;
      final List<PlaceModel> newPlaces = list.map((item) => PlaceModel.fromJson(item as Map<String, dynamic>)).toList();
      
      // Confirm replacement
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore Data?'),
          content: Text(
            'This will clear your current database and restore ${newPlaces.length} items. This action cannot be undone. Are you sure you want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Restore'),
            ),
          ],
        ),
      );
      
      if (confirm != true) return;
      
      // Restore
      final box = Hive.box<PlaceModel>('places_box');
      await box.clear();
      for (final p in newPlaces) {
        await box.put(p.id, p);
      }
      
      // Refresh Provider
      ref.invalidate(placesListProvider);
      
      // Restore settings if present
      if (backupMap.containsKey('settings')) {
        final settings = backupMap['settings'] as Map<String, dynamic>;
        
        if (settings.containsKey('themeMode')) {
          final modeStr = settings['themeMode'] as String;
          ThemeMode mode = ThemeMode.system;
          if (modeStr == 'light') mode = ThemeMode.light;
          if (modeStr == 'dark') mode = ThemeMode.dark;
          await ref.read(themeModeProvider.notifier).setThemeMode(mode);
        }
        if (settings.containsKey('accentColor')) {
          await ref.read(accentColorProvider.notifier).setAccentColor(settings['accentColor'] as String);
        }
      }
      
      _showSuccessDialog(
        context,
        'Restore Successful',
        'Successfully restored ${newPlaces.length} places and applied configuration.',
      );
    } catch (e) {
      _showErrorDialog(context, 'Restore Failed', 'An error occurred during restore: $e');
    }
  }

  Future<void> _loadDemoData(BuildContext context, WidgetRef ref) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Demo Data?'),
        content: const Text('This will add 30 pre-configured locations to your diary (Restaurants, Clothing Stores, and sightseeing places). Proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Load'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      final box = Hive.box<PlaceModel>('places_box');
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      
      // Add Restaurants
      for (final r in DemoData.restaurants) {
        final pm = PlaceModel(
          id: r.id,
          name: r.name,
          description: r.description,
          category: r.category,
          budget: r.budget,
          location: r.location,
          rating: r.rating,
          isVisited: r.isVisited,
          isWishlist: r.isWishlist,
          imageUrl: r.imageUrl,
          type: r.type,
          latitude: r.latitude,
          longitude: r.longitude,
          dateAdded: todayStr,
          lastUpdated: todayStr,
          imageType: r.imageType,
          isDemoData: true,
        );
        await box.put(pm.id, pm);
      }
      
      // Add Clothing
      for (final c in DemoData.clothingStores) {
        final pm = PlaceModel(
          id: c.id,
          name: c.name,
          description: c.description,
          category: c.category,
          budget: c.budget,
          location: c.location,
          rating: c.rating,
          isVisited: c.isVisited,
          isWishlist: c.isWishlist,
          imageUrl: c.imageUrl,
          type: c.type,
          latitude: c.latitude,
          longitude: c.longitude,
          dateAdded: todayStr,
          lastUpdated: todayStr,
          imageType: c.imageType,
          isDemoData: true,
        );
        await box.put(pm.id, pm);
      }
      
      // Add Visits
      for (final v in DemoData.visits) {
        final pm = PlaceModel(
          id: v.id,
          name: v.name,
          description: v.description,
          category: v.category,
          budget: v.budget,
          location: v.location,
          rating: v.rating,
          isVisited: v.isVisited,
          isWishlist: v.isWishlist,
          imageUrl: v.imageUrl,
          type: v.type,
          entryFee: v.entryFee,
          bestTime: v.bestTime,
          latitude: v.latitude,
          longitude: v.longitude,
          dateAdded: todayStr,
          lastUpdated: todayStr,
          imageType: v.imageType,
          isDemoData: true,
        );
        await box.put(pm.id, pm);
      }
      
      ref.invalidate(placesListProvider);
      _showSuccessDialog(context, 'Demo Data Loaded', 'Successfully loaded 30 demo places!');
    } catch (e) {
      _showErrorDialog(context, 'Failed to Load', 'Could not load demo data: $e');
    }
  }

  Future<void> _clearDemoData(BuildContext context, WidgetRef ref) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Demo Data?'),
        content: const Text('This will safely delete all demo-loaded locations from your diary. Your custom entries will NOT be touched. Proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      final box = Hive.box<PlaceModel>('places_box');
      final keysToDelete = <dynamic>[];
      for (final key in box.keys) {
        final place = box.get(key);
        if (place != null && place.isDemoData) {
          keysToDelete.add(key);
        }
      }
      await box.deleteAll(keysToDelete);
      ref.invalidate(placesListProvider);
      _showSuccessDialog(context, 'Demo Data Cleared', 'Successfully removed all demo-loaded places.');
    } catch (e) {
      _showErrorDialog(context, 'Failed to Clear', 'Could not clear demo data: $e');
    }
  }

  void _showDarkModeSelector(BuildContext context, WidgetRef ref) {
    final activeMode = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSizes.gapH24,
                Text('Select Dark Mode Option', style: AppTypography.title.copyWith(fontWeight: FontWeight.bold)),
                AppSizes.gapH16,
                ListTile(
                  leading: const Icon(Icons.wb_sunny_rounded),
                  title: const Text('Light Mode'),
                  trailing: activeMode == ThemeMode.light ? Icon(Icons.check_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.dark_mode_rounded),
                  title: const Text('Dark Mode'),
                  trailing: activeMode == ThemeMode.dark ? Icon(Icons.check_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_suggest_rounded),
                  title: const Text('System Default'),
                  trailing: activeMode == ThemeMode.system ? Icon(Icons.check_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
                AppSizes.gapH24,
              ],
            ),
          ),
        );
      },
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p16),
        children: [
          _buildSectionHeader('Data Management'),
          _buildSettingsTile(
            context,
            icon: Icons.cloud_upload_rounded,
            title: 'Backup Data',
            subtitle: 'Backup saved locations to local device storage.',
            onTap: () => _backupData(context, ref),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.cloud_download_rounded,
            title: 'Restore Data',
            subtitle: 'Restore places from a previous backup file.',
            onTap: () => _restoreData(context, ref),
          ),
          const Divider(height: 32),

          _buildSectionHeader('Preferences'),
          _buildSettingsTile(
            context,
            icon: Icons.palette_rounded,
            title: 'Theme Color',
            subtitle: 'Customize brand highlights immediately.',
            trailing: Text(
              themeColor[0].toUpperCase() + themeColor.substring(1),
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
            onTap: () => context.push('/settings/theme-gallery'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: 'Switch display visual layout colors.',
            trailing: Text(
              _getThemeModeLabel(themeMode),
              style: TextStyle(color: AppColors.textSecondary),
            ),
            onTap: () => _showDarkModeSelector(context, ref),
          ),
          const Divider(height: 32),

          _buildSectionHeader('Demo Data'),
          _buildSettingsTile(
            context,
            icon: Icons.playlist_add_rounded,
            title: 'Load Demo Data',
            subtitle: 'Insert 30 premium restaurants, boutiques & travel spots.',
            onTap: () => _loadDemoData(context, ref),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.playlist_remove_rounded,
            title: 'Clear Demo Data',
            subtitle: 'Safely remove all demo-loaded entries.',
            onTap: () => _clearDemoData(context, ref),
          ),
          const Divider(height: 32),

          _buildSectionHeader('App Info & Support'),
          _buildSettingsTile(
            context,
            icon: Icons.security_rounded,
            title: 'Privacy Policy',
            subtitle: 'Read our strict offline data privacy details.',
            onTap: () => context.push('/settings/privacy-policy'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_rounded,
            title: 'Terms & Conditions',
            subtitle: 'Review legal terms of application usage.',
            onTap: () => context.push('/settings/terms-conditions'),
          ),
          
          // Repositioned Clean App Info Footer
          const Divider(height: 32),
          AppSizes.gapH16,
          Center(
            child: Column(
              children: [
                GNLogo(
                  size: 40,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                AppSizes.gapH8,
                Text(
                  'GoNext',
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Version 1.0.0',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          AppSizes.gapH24,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.overline.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTypography.bodyEmphasis),
      subtitle: Text(subtitle, style: AppTypography.caption),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
