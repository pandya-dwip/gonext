import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_card.dart';
import '../../../../shared/components/gn_chip.dart';
import '../../../../shared/components/gn_button.dart';
import '../../data/models/place_model.dart';
import '../providers/place_provider.dart';
import 'restaurants_page.dart'; // Import GNEmptyState

/// ClothingPage displays boutique streetwear and vintage collections
/// featuring a vertical card ratio (4:5 crop) with local/network/asset lifestyle images.
class ClothingPage extends ConsumerStatefulWidget {
  const ClothingPage({super.key});

  @override
  ConsumerState<ClothingPage> createState() => _ClothingPageState();
}

class _ClothingPageState extends ConsumerState<ClothingPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(placeSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentSort = ref.read(placeSortOptionProvider);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Sort Boutique Stores By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ...PlaceSortOption.values.map((opt) {
                String label = '';
                switch (opt) {
                  case PlaceSortOption.newest:
                    label = 'Recently Added';
                    break;
                  case PlaceSortOption.oldest:
                    label = 'Oldest Added';
                    break;
                  case PlaceSortOption.highestRated:
                    label = 'Highest Rated';
                    break;
                  case PlaceSortOption.alphabetical:
                    label = 'Alphabetical (A-Z)';
                    break;
                  case PlaceSortOption.recentlyUpdated:
                    label = 'Recently Updated';
                    break;
                }
                return RadioListTile<PlaceSortOption>(
                  title: Text(label),
                  value: opt,
                  groupValue: currentSort,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(placeSortOptionProvider.notifier).state = val;
                    }
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions(String filterType) {
    if (filterType == 'All') {
      ref.read(clothingTypeFilterProvider.notifier).state = 'All';
      ref.read(clothingBudgetFilterProvider.notifier).state = 'All';
      ref.read(clothingVisitedFilterProvider.notifier).state = 'All';
      return;
    }

    if (filterType == 'Store Type') {
      final allPlaces = ref.read(placesListProvider).value ?? [];
      final types = allPlaces
          .where((p) => p.type == 'clothing')
          .map((p) => p.category)
          .toSet()
          .toList();
      types.sort();

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Store Types'),
                  onTap: () {
                    ref.read(clothingTypeFilterProvider.notifier).state = 'All';
                    Navigator.pop(context);
                  },
                ),
                ...types.map((t) => ListTile(
                  title: Text(t),
                  onTap: () {
                    ref.read(clothingTypeFilterProvider.notifier).state = t;
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          );
        },
      );
    } else if (filterType == 'Budget') {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('All Budgets'),
                  onTap: () {
                    ref.read(clothingBudgetFilterProvider.notifier).state = 'All';
                    Navigator.pop(context);
                  },
                ),
                ...['Low Range', 'Mid Range', 'High Range', 'Luxury/Premium'].map((b) => ListTile(
                  title: Text(b),
                  onTap: () {
                    ref.read(clothingBudgetFilterProvider.notifier).state = b;
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          );
        },
      );
    } else if (filterType == 'Wishlist-only') {
      final current = ref.read(clothingVisitedFilterProvider);
      ref.read(clothingVisitedFilterProvider.notifier).state =
          current == 'Wishlist-only' ? 'All' : 'Wishlist-only';
    }
  }

  @override
  Widget build(BuildContext context) {
    final boutiques = ref.watch(filteredClothingProvider);

    final activeType = ref.watch(clothingTypeFilterProvider);
    final activeBudget = ref.watch(clothingBudgetFilterProvider);
    final activeVisited = ref.watch(clothingVisitedFilterProvider);

    final hasActiveFilter = activeType != 'All' ||
        activeBudget != 'All' ||
        activeVisited == 'Wishlist-only';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title Block
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clothing',
                    style: AppTypography.titleLarge.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${boutiques.length} saved boutiques',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),

            // Pinned Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceFaint,
                  borderRadius: BorderRadius.circular(AppSizes.rPill),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    AppSizes.gapW8,
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          ref.read(placeSearchQueryProvider.notifier).state = val;
                        },
                        decoration: InputDecoration(
                          hintText: 'Search brand, type, or place name...',
                          hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showSortBottomSheet,
                      child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            AppSizes.gapH12,

            // Horizontal Filter Chips list
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('All', !hasActiveFilter),
                  AppSizes.gapW8,
                  _buildFilterChip('Store Type', activeType != 'All', suffixText: activeType != 'All' ? activeType : null),
                  AppSizes.gapW8,
                  _buildFilterChip('Budget', activeBudget != 'All', suffixText: activeBudget != 'All' ? activeBudget : null),
                  AppSizes.gapW8,
                  _buildFilterChip('Wishlist-only', activeVisited == 'Wishlist-only'),
                ],
              ),
            ),
            AppSizes.gapH16,

            // 4:5 Card Grid List OR Empty State
            Expanded(
              child: boutiques.isEmpty
                  ? GNEmptyState(
                      title: 'No Clothing Stores Yet',
                      subtitle: 'Save boutiques, streetwear hubs, and fashion ateliers.',
                      buttonLabel: 'Add Clothing Store',
                      icon: Icons.checkroom_rounded,
                      onButtonPressed: () => context.push('/add-clothing'),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
                      itemCount: boutiques.length,
                      separatorBuilder: (context, index) => AppSizes.gapH24,
                      itemBuilder: (context, index) {
                        final store = boutiques[index];

                        return Column(
                          children: [
                            GNCard(
                              variant: GNCardVariant.standard,
                              title: store.name,
                              subtitle: '${store.category} • ${store.budget}',
                              rating: store.rating,
                              isWishlist: store.isWishlist,
                              icon: Icons.checkroom_rounded,
                              imageUrl: store.imageUrl,
                              imageType: store.imageType,
                              imageAspectRatio: 4 / 5, // Custom clothing 4:5 crop ratio
                              location: store.location,
                              category: store.category,
                              onTap: () => context.push('/clothing-detail/${store.id}'),
                              onWishlistTap: () async {
                                final updated = PlaceModel(
                                  id: store.id,
                                  name: store.name,
                                  description: store.description,
                                  category: store.category,
                                  budget: store.budget,
                                  location: store.location,
                                  rating: store.rating,
                                  isVisited: store.isVisited,
                                  isWishlist: !store.isWishlist,
                                  imageUrl: store.imageUrl,
                                  type: store.type,
                                  entryFee: store.entryFee,
                                  bestTime: store.bestTime,
                                  latitude: store.latitude,
                                  longitude: store.longitude,
                                  dateAdded: store.dateAdded,
                                  lastUpdated: store.lastUpdated,
                                  imageType: store.imageType,
                                );
                                await ref.read(placesListProvider.notifier).updatePlace(updated);
                              },
                            ),
                            AppSizes.gapH8,
                            Row(
                              children: [
                                GNChip(
                                  label: store.category,
                                  variant: GNChipVariant.status,
                                  statusTone: GNStatusTone.info,
                                ),
                                AppSizes.gapW8,
                                GNChip(
                                  label: store.budget,
                                  variant: GNChipVariant.status,
                                  statusTone: GNStatusTone.success,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {String? suffixText}) {
    final displayLabel = suffixText != null ? '$label ($suffixText)' : label;
    return GNChip(
      label: displayLabel,
      variant: GNChipVariant.filter,
      isSelected: isSelected,
      onTap: () => _showFilterOptions(label),
    );
  }
}
