import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/theme_gallery_data.dart';
import '../providers/settings_provider.dart';

/// ThemeGalleryPage displays 50+ premium accent color themes.
/// Includes real-time search filtering, color swatch previews, active checkmark,
/// and tap animations that immediately persist and update the entire application.
class ThemeGalleryPage extends ConsumerStatefulWidget {
  const ThemeGalleryPage({super.key});

  @override
  ConsumerState<ThemeGalleryPage> createState() => _ThemeGalleryPageState();
}

class _ThemeGalleryPageState extends ConsumerState<ThemeGalleryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = ref.watch(accentColorProvider);

    // Filter themes based on search query
    final filteredThemes = kThemeGallery.where((theme) {
      return theme.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Theme Colors', style: AppTypography.title),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceFaint,
                borderRadius: BorderRadius.circular(AppSizes.r16),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  AppSizes.gapW12,
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.body,
                      decoration: InputDecoration(
                        hintText: 'Search themes...',
                        hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ),

          // Main Themes Grid/List View
          Expanded(
            child: filteredThemes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.palette_outlined, size: 64, color: AppColors.textMuted),
                        AppSizes.gapH16,
                        Text(
                          'No themes match your search',
                          style: AppTypography.bodyEmphasis.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
                    itemCount: filteredThemes.length,
                    itemBuilder: (context, index) {
                      final theme = filteredThemes[index];
                      final isSelected = activeColor.toLowerCase() == theme.name.toLowerCase();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.p12),
                        child: Material(
                          color: isSelected
                              ? theme.primary.withValues(alpha: 0.08)
                              : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(AppSizes.r20),
                          child: InkWell(
                            onTap: () {
                              ref.read(accentColorProvider.notifier).setAccentColor(theme.name);
                            },
                            borderRadius: BorderRadius.circular(AppSizes.r20),
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.p16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSizes.r20),
                                border: Border.all(
                                  color: isSelected ? theme.primary : AppColors.border,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Preview swatches (Primary and Secondary circles)
                                  Stack(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: theme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: theme.secondary,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSizes.gapW16,

                                  // Theme Name & Colors info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          theme.name,
                                          style: AppTypography.bodyEmphasis.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? theme.primary : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Primary: #${theme.primary.value.toRadixString(16).substring(2).toUpperCase()}   Secondary: #${theme.secondary.value.toRadixString(16).substring(2).toUpperCase()}',
                                          style: AppTypography.overline.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Active Indicator Icon
                                  if (isSelected)
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: theme.primary,
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
