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

/// VisitsPage displays sightseeing nature and landmarks wishlists
/// utilizing wide 16:9 crop ratios resembling travel postcards.
class VisitsPage extends ConsumerStatefulWidget {
  const VisitsPage({super.key});

  @override
  ConsumerState<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends ConsumerState<VisitsPage> {
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
                child: Text('Sort Travel Spots By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    final visits = ref.watch(filteredVisitsProvider);
    final allPlaces = ref.watch(placesListProvider).value ?? [];
    final rawVisitsEmpty = allPlaces.where((p) => p.type == 'visit').isEmpty;

    final activeCategories = ref.watch(visitCategoryFilterProvider);
    final activePrices = ref.watch(visitBudgetFilterProvider);
    final activeVisited = ref.watch(visitVisitedFilterProvider);
    final activeWishlist = ref.watch(visitWishlistFilterProvider);

    final availableCategories = ref.watch(availableVisitCategoriesProvider);
    final availablePrices = ref.watch(availableVisitBudgetsProvider);

    final hasActiveFilter = activeCategories.isNotEmpty ||
        activePrices.isNotEmpty ||
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
                    'Places to Visit',
                    style: AppTypography.titleLarge.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${visits.length} saved travel spots',
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
                          hintText: 'Search landmark, category, or place name...',
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
                        ref.read(visitCategoryFilterProvider.notifier).clear();
                        ref.read(visitBudgetFilterProvider.notifier).clear();
                        ref.read(visitVisitedFilterProvider.notifier).clear();
                        ref.read(visitWishlistFilterProvider.notifier).clear();
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
                        onTap: () => ref.read(visitVisitedFilterProvider.notifier).toggle(status),
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
                        onTap: () => ref.read(visitWishlistFilterProvider.notifier).toggle(status),
                      ),
                    );
                  }),
                  // Entry fees (only existing: Paid/Free)
                  ...availablePrices.map((p) {
                    final isSelected = activePrices.contains(p);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GNChip(
                        label: p == 'Free' ? 'Free Entry' : 'Paid Entry',
                        variant: GNChipVariant.filter,
                        isSelected: isSelected,
                        onTap: () => ref.read(visitBudgetFilterProvider.notifier).toggle(p),
                      ),
                    );
                  }),
                  // Categories (only existing)
                  ...availableCategories.map((c) {
                    final isSelected = activeCategories.contains(c);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GNChip(
                        label: c,
                        variant: GNChipVariant.filter,
                        isSelected: isSelected,
                        onTap: () => ref.read(visitCategoryFilterProvider.notifier).toggle(c),
                      ),
                    );
                  }),
                ],
              ),
            ),
            AppSizes.gapH16,

            // Postcard 16:9 card list scroll OR empty state
            Expanded(
              child: rawVisitsEmpty
                  ? GNEmptyState(
                      title: 'No Places Yet',
                      description: 'Save heritage sites, national parks, and viewpoints.',
                      actionLabel: 'Add Travel Spot',
                      icon: Icons.travel_explore_rounded,
                      onActionPressed: () => context.push('/add-visit'),
                    )
                  : (visits.isEmpty
                      ? GNEmptyState(
                          title: 'No places match your filters.',
                          description: 'Try removing some filters.',
                          actionLabel: 'Clear Filters',
                          icon: Icons.filter_list_off_rounded,
                          onActionPressed: () {
                            ref.read(visitCategoryFilterProvider.notifier).clear();
                            ref.read(visitBudgetFilterProvider.notifier).clear();
                            ref.read(visitVisitedFilterProvider.notifier).clear();
                            ref.read(visitWishlistFilterProvider.notifier).clear();
                          },
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
                          itemCount: visits.length,
                          separatorBuilder: (context, index) => AppSizes.gapH24,
                          itemBuilder: (context, index) {
                            final place = visits[index];

                            return GNCard(
                              variant: GNCardVariant.standard,
                              title: place.name,
                              subtitle: '${place.category} • ${place.entryFee ?? 'Free'}',
                              rating: place.rating,
                              isWishlist: place.isWishlist,
                              icon: Icons.travel_explore_rounded,
                              imageUrl: place.imageUrl,
                              imageType: place.imageType,
                              imageAspectRatio: 16 / 9, // Postcard 16:9 aspect ratio
                              location: place.location,
                              category: place.category,
                              onTap: () => context.push('/place-detail/${place.id}'),
                              onWishlistTap: () async {
                                final updated = PlaceModel(
                                  id: place.id,
                                  name: place.name,
                                  description: place.description,
                                  category: place.category,
                                  budget: place.budget,
                                  location: place.location,
                                  rating: place.rating,
                                  isVisited: place.isVisited,
                                  isWishlist: !place.isWishlist,
                                  imageUrl: place.imageUrl,
                                  type: place.type,
                                  entryFee: place.entryFee,
                                  bestTime: place.bestTime,
                                  latitude: place.latitude,
                                  longitude: place.longitude,
                                  dateAdded: place.dateAdded,
                                  lastUpdated: place.lastUpdated,
                                  imageType: place.imageType,
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
