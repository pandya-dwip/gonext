import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/theme_gallery_data.dart';
import '../providers/settings_provider.dart';

/// Redesigned premium ThemeGalleryPage.
/// Organizes themes into collections, renders miniature device-mockup theme previews,
/// supports real-time search, filters by category chips, and triggers instant dynamic refreshes.
class ThemeGalleryPage extends ConsumerStatefulWidget {
  const ThemeGalleryPage({super.key});

  @override
  ConsumerState<ThemeGalleryPage> createState() => _ThemeGalleryPageState();
}

class _ThemeGalleryPageState extends ConsumerState<ThemeGalleryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All'; // 'All', 'Green', 'Blue', 'Purple', 'Warm', 'Neutral', 'Dark', 'Minimal'

  final List<String> _categories = [
    'All',
    'Green',
    'Blue',
    'Purple',
    'Warm',
    'Neutral',
    'Dark',
    'Minimal',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Re-watch settings provider to rebuild on accent changes
    final activeColor = ref.watch(accentColorProvider);
    ref.watch(themeModeProvider);

    // 1. Filter themes by search query
    var filteredThemes = kThemeGallery.where((theme) {
      final matchesSearch = theme.name.toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (_selectedCategoryFilter == 'All') {
        return matchesSearch;
      } else {
        final matchesCategory = theme.category.toLowerCase().contains(_selectedCategoryFilter.toLowerCase());
        return matchesSearch && matchesCategory;
      }
    }).toList();

    // 2. Group themes by category
    final Map<String, List<ThemeSpec>> groupedThemes = {};
    for (final theme in filteredThemes) {
      groupedThemes.putIfAbsent(theme.category, () => []).add(theme);
    }

    // Order categories logically
    final categoryOrder = [
      'Green Collection',
      'Blue Collection',
      'Purple Collection',
      'Warm Collection',
      'Neutral Collection',
      'Dark Collection',
      'Minimal Collection',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Theme Gallery', style: AppTypography.title),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
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

          // Horizontal Category filter chips bar
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: FilterChip(
                    label: Text(
                      cat == 'All' ? 'All Collections' : '$cat Collection',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: AppColors.surfaceFaint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.rPill),
                      side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryFilter = cat;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          AppSizes.gapH8,

          // Main Categorized Grid View
          Expanded(
            child: filteredThemes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.palette_outlined, size: 64, color: AppColors.textMuted),
                        AppSizes.gapH16,
                        Text(
                          'No matching themes',
                          style: AppTypography.bodyEmphasis.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                    itemCount: categoryOrder.length,
                    itemBuilder: (context, index) {
                      final categoryTitle = categoryOrder[index];
                      final themesInCategory = groupedThemes[categoryTitle] ?? [];
                      if (themesInCategory.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Visually separated Category Header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(categoryTitle),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                AppSizes.gapW8,
                                Text(
                                  categoryTitle,
                                  style: AppTypography.title.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Theme Cards Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: AppSizes.p12,
                              crossAxisSpacing: AppSizes.p12,
                              childAspectRatio: 1.15,
                            ),
                            itemCount: themesInCategory.length,
                            itemBuilder: (context, idx) {
                              final theme = themesInCategory[idx];
                              final isSelected = activeColor.toLowerCase() == theme.name.toLowerCase();

                              return Material(
                                color: isSelected
                                    ? theme.primary.withValues(alpha: 0.08)
                                    : AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(AppSizes.r20),
                                child: InkWell(
                                  onTap: () {
                                    ref.read(accentColorProvider.notifier).setAccentColor(theme.name);
                                  },
                                  borderRadius: BorderRadius.circular(AppSizes.r20),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppSizes.r20),
                                      border: Border.all(
                                        color: isSelected ? theme.primary : AppColors.border,
                                        width: isSelected ? 2.0 : 1.0,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(AppSizes.p12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Miniature app mockup preview
                                        Container(
                                          height: 48,
                                          width: 74,
                                          decoration: BoxDecoration(
                                            color: AppColors.isDark ? const Color(0xFF141414) : const Color(0xFFF4F6F5),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isSelected ? theme.primary : AppColors.border,
                                              width: isSelected ? 1.5 : 1.0,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              // AppBar bar
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                height: 10,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: theme.primary,
                                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                                                  ),
                                                ),
                                              ),
                                              // Side card preview
                                              Positioned(
                                                top: 14,
                                                left: 6,
                                                right: 20,
                                                bottom: 4,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                                    borderRadius: BorderRadius.circular(3),
                                                    boxShadow: AppSizes.shadowLevel1,
                                                  ),
                                                ),
                                              ),
                                              // FAB indicator
                                              Positioned(
                                                bottom: 6,
                                                right: 6,
                                                width: 8,
                                                height: 8,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: theme.secondary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Theme Details
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                theme.name,
                                                style: AppTypography.bodyEmphasis.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: isSelected ? theme.primary : AppColors.textPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isSelected)
                                              CircleAvatar(
                                                radius: 10,
                                                backgroundColor: theme.primary,
                                                child: const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          AppSizes.gapH16,
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Green Collection':
        return Colors.green;
      case 'Blue Collection':
        return Colors.blue;
      case 'Purple Collection':
        return Colors.purple;
      case 'Warm Collection':
        return Colors.orange;
      case 'Neutral Collection':
        return Colors.grey;
      case 'Dark Collection':
        return Colors.indigo;
      case 'Minimal Collection':
      default:
        return AppColors.textSecondary;
    }
  }
}
