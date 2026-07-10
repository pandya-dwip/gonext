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

/// RestaurantsPage displays saved dining spots with search, chips filters,
/// and vertical 4:3 standard cards with local/network/asset photography.
class RestaurantsPage extends ConsumerStatefulWidget {
  const RestaurantsPage({super.key});

  @override
  ConsumerState<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends ConsumerState<RestaurantsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate search text from provider if it exists
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
                child: Text('Sort Restaurants By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    final restaurants = ref.watch(filteredRestaurantsProvider);
    final allPlaces = ref.watch(placesListProvider).value ?? [];
    final rawRestaurantsEmpty = allPlaces.where((p) => p.type == 'restaurant').isEmpty;

    final activeCuisines = ref.watch(restaurantCuisineFilterProvider);
    final activeBudgets = ref.watch(restaurantBudgetFilterProvider);
    final activeVisited = ref.watch(restaurantVisitedFilterProvider);
    final activeWishlist = ref.watch(restaurantWishlistFilterProvider);

    final availableCuisines = ref.watch(availableRestaurantCuisinesProvider);
    final availableBudgets = ref.watch(availableRestaurantBudgetsProvider);

    final hasActiveFilter = activeCuisines.isNotEmpty ||
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
            // Collapsing Header Title Block
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurants',
                    style: AppTypography.titleLarge.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${restaurants.length} saved places',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),

            // Pinned Search Bar (pill-shaped)
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
                          hintText: 'Search cuisine or place name...',
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
                        ref.read(restaurantCuisineFilterProvider.notifier).clear();
                        ref.read(restaurantBudgetFilterProvider.notifier).clear();
                        ref.read(restaurantVisitedFilterProvider.notifier).clear();
                        ref.read(restaurantWishlistFilterProvider.notifier).clear();
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
                        onTap: () => ref.read(restaurantVisitedFilterProvider.notifier).toggle(status),
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
                        onTap: () => ref.read(restaurantWishlistFilterProvider.notifier).toggle(status),
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
                        onTap: () => ref.read(restaurantBudgetFilterProvider.notifier).toggle(b),
                      ),
                    );
                  }),
                  // Cuisines/Categories (only existing)
                  ...availableCuisines.map((c) {
                    final isSelected = activeCuisines.contains(c);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GNChip(
                        label: c,
                        variant: GNChipVariant.filter,
                        isSelected: isSelected,
                        onTap: () => ref.read(restaurantCuisineFilterProvider.notifier).toggle(c),
                      ),
                    );
                  }),
                ],
              ),
            ),
            AppSizes.gapH16,

            // Standard 4:3 card list scroll OR empty state
            Expanded(
              child: rawRestaurantsEmpty
                  ? GNEmptyState(
                      title: 'No Restaurants Yet',
                      description: 'Save dining spots, bistros, and cafés to your dashboard.',
                      actionLabel: 'Add Restaurant',
                      icon: Icons.restaurant_rounded,
                      onActionPressed: () => context.push('/add-restaurant'),
                    )
                  : (restaurants.isEmpty
                      ? GNEmptyState(
                          title: 'No places match your filters.',
                          description: 'Try removing some filters.',
                          actionLabel: 'Clear Filters',
                          icon: Icons.filter_list_off_rounded,
                          onActionPressed: () {
                            ref.read(restaurantCuisineFilterProvider.notifier).clear();
                            ref.read(restaurantBudgetFilterProvider.notifier).clear();
                            ref.read(restaurantVisitedFilterProvider.notifier).clear();
                            ref.read(restaurantWishlistFilterProvider.notifier).clear();
                          },
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
                          itemCount: restaurants.length,
                          separatorBuilder: (context, index) => AppSizes.gapH24,
                          itemBuilder: (context, index) {
                            final rest = restaurants[index];

                            return GNCard(
                              variant: GNCardVariant.standard,
                              title: rest.name,
                              subtitle: '${rest.category} • ${rest.budget}',
                              rating: rest.rating,
                              isWishlist: rest.isWishlist,
                              icon: Icons.restaurant_rounded,
                              imageUrl: rest.imageUrl,
                              imageType: rest.imageType,
                              imageAspectRatio: 4 / 3, // Standard M3 4:3 crop
                              location: rest.location,
                              category: rest.category,
                              onTap: () => context.push('/restaurant-detail/${rest.id}'),
                              onWishlistTap: () async {
                                final updated = PlaceModel(
                                  id: rest.id,
                                  name: rest.name,
                                  description: rest.description,
                                  category: rest.category,
                                  budget: rest.budget,
                                  location: rest.location,
                                  rating: rest.rating,
                                  isVisited: rest.isVisited,
                                  isWishlist: !rest.isWishlist,
                                  imageUrl: rest.imageUrl,
                                  type: rest.type,
                                  entryFee: rest.entryFee,
                                  bestTime: rest.bestTime,
                                  latitude: rest.latitude,
                                  longitude: rest.longitude,
                                  dateAdded: rest.dateAdded,
                                  lastUpdated: rest.lastUpdated,
                                  imageType: rest.imageType,
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
