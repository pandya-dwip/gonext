import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_card.dart';
import '../../../../shared/components/gn_chip.dart';
import '../../../../shared/components/gn_empty_state.dart';
import '../../data/models/place_model.dart';
import '../providers/place_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final boutiques = ref.watch(filteredClothingProvider);
    final allPlaces = ref.watch(placesListProvider).value ?? [];
    final rawClothingEmpty = allPlaces.where((p) => p.type == 'clothing').isEmpty;

    final activeTypes = ref.watch(clothingTypeFilterProvider);
    final activeBudgets = ref.watch(clothingBudgetFilterProvider);
    final activeVisited = ref.watch(clothingVisitedFilterProvider);
    final activeWishlist = ref.watch(clothingWishlistFilterProvider);

    final availableTypes = ref.watch(availableClothingTypesProvider);
    final availableBudgets = ref.watch(availableClothingBudgetsProvider);

    final hasActiveFilter = activeTypes.isNotEmpty ||
        activeBudgets.isNotEmpty ||
        activeVisited.isNotEmpty ||
        activeWishlist.isNotEmpty;

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
                    Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
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
                      child: Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
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
                  if (hasActiveFilter) ...[
                    GNChip(
                      label: 'Clear Filters',
                      variant: GNChipVariant.filter,
                      isSelected: false,
                      leadingIcon: Icons.clear_all_rounded,
                      onTap: () {
                        ref.read(clothingTypeFilterProvider.notifier).clear();
                        ref.read(clothingBudgetFilterProvider.notifier).clear();
                        ref.read(clothingVisitedFilterProvider.notifier).clear();
                        ref.read(clothingWishlistFilterProvider.notifier).clear();
                      },
                    ),
                    AppSizes.gapW8,
                  ],
                  // Visited status filters
                  ...['Visited', 'Not Visited'].map((status) {
                    final isSelected = activeVisited.contains(status);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GNChip(
                        label: status,
                        variant: GNChipVariant.filter,
                        isSelected: isSelected,
                        onTap: () => ref.read(clothingVisitedFilterProvider.notifier).toggle(status),
                      ),
                    );
                  }),
                  // Wishlist status filters
                  ...['Wishlist', 'Not Wishlist'].map((status) {
                    final isSelected = activeWishlist.contains(status);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GNChip(
                        label: status,
                        variant: GNChipVariant.filter,
                        isSelected: isSelected,
                        onTap: () => ref.read(clothingWishlistFilterProvider.notifier).toggle(status),
                      ),
                    );
                  }),
                  // Budgets (only existing)
                  ...availableBudgets.map((b) {
                    final isSelected = activeBudgets.contains(b);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GNChip(
                        label: b,
                        variant: GNChipVariant.filter,
                        isSelected: isSelected,
                        onTap: () => ref.read(clothingBudgetFilterProvider.notifier).toggle(b),
                      ),
                    );
                  }),
                  // Store Types (only existing)
                  ...availableTypes.map((t) {
                    final isSelected = activeTypes.contains(t);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GNChip(
                        label: t,
                        variant: GNChipVariant.filter,
                        isSelected: isSelected,
                        onTap: () => ref.read(clothingTypeFilterProvider.notifier).toggle(t),
                      ),
                    );
                  }),
                ],
              ),
            ),
            AppSizes.gapH16,

            // 4:5 Card Grid List OR Empty State
            Expanded(
              child: rawClothingEmpty
                  ? GNEmptyState(
                      title: 'No Clothing Stores Yet',
                      description: 'Save boutiques, streetwear hubs, and fashion ateliers.',
                      actionLabel: 'Add Clothing Store',
                      icon: Icons.checkroom_rounded,
                      onActionPressed: () => context.push('/add-clothing'),
                    )
                  : (boutiques.isEmpty
                      ? GNEmptyState(
                          title: 'No places match your filters.',
                          description: 'Try removing some filters.',
                          actionLabel: 'Clear Filters',
                          icon: Icons.filter_list_off_rounded,
                          onActionPressed: () {
                            ref.read(clothingTypeFilterProvider.notifier).clear();
                            ref.read(clothingBudgetFilterProvider.notifier).clear();
                            ref.read(clothingVisitedFilterProvider.notifier).clear();
                            ref.read(clothingWishlistFilterProvider.notifier).clear();
                          },
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
                          itemCount: boutiques.length,
                          separatorBuilder: (context, index) => AppSizes.gapH24,
                          itemBuilder: (context, index) {
                            final store = boutiques[index];

                            return GNCard(
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
                            );
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
