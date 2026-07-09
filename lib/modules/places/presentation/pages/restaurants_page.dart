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

  void _showFilterOptions(String filterType) {
    if (filterType == 'All') {
      ref.read(restaurantCuisineFilterProvider.notifier).state = 'All';
      ref.read(restaurantBudgetFilterProvider.notifier).state = 'All';
      ref.read(restaurantVisitedFilterProvider.notifier).state = 'All';
      ref.read(restaurantRatingFilterProvider.notifier).state = null;
      return;
    }

    if (filterType == 'Cuisine') {
      // Extract unique cuisines from database
      final allPlaces = ref.read(placesListProvider).value ?? [];
      final cuisines = allPlaces
          .where((p) => p.type == 'restaurant')
          .map((p) => p.category)
          .toSet()
          .toList();
      cuisines.sort();

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Cuisines'),
                  onTap: () {
                    ref.read(restaurantCuisineFilterProvider.notifier).state = 'All';
                    Navigator.pop(context);
                  },
                ),
                ...cuisines.map((c) => ListTile(
                  title: Text(c),
                  onTap: () {
                    ref.read(restaurantCuisineFilterProvider.notifier).state = c;
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
                    ref.read(restaurantBudgetFilterProvider.notifier).state = 'All';
                    Navigator.pop(context);
                  },
                ),
                ...['₹', '₹₹', '₹₹₹'].map((b) => ListTile(
                  title: Text(b == '₹' ? '₹ (Inexpensive)' : b == '₹₹' ? '₹₹ (Moderate)' : '₹₹₹ (Expensive)'),
                  onTap: () {
                    ref.read(restaurantBudgetFilterProvider.notifier).state = b;
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          );
        },
      );
    } else if (filterType == 'Rating') {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Any Rating'),
                  onTap: () {
                    ref.read(restaurantRatingFilterProvider.notifier).state = null;
                    Navigator.pop(context);
                  },
                ),
                ...[3.0, 4.0, 4.5].map((r) => ListTile(
                  title: Text('$r+ Stars'),
                  onTap: () {
                    ref.read(restaurantRatingFilterProvider.notifier).state = r;
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          );
        },
      );
    } else if (filterType == 'Wishlist-only') {
      final current = ref.read(restaurantVisitedFilterProvider);
      ref.read(restaurantVisitedFilterProvider.notifier).state =
          current == 'Wishlist-only' ? 'All' : 'Wishlist-only';
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(filteredRestaurantsProvider);

    final activeCuisine = ref.watch(restaurantCuisineFilterProvider);
    final activeBudget = ref.watch(restaurantBudgetFilterProvider);
    final activeVisited = ref.watch(restaurantVisitedFilterProvider);
    final activeRating = ref.watch(restaurantRatingFilterProvider);

    final hasActiveFilter = activeCuisine != 'All' ||
        activeBudget != 'All' ||
        activeVisited == 'Wishlist-only' ||
        activeRating != null;

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
                    const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
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
                  _buildFilterChip('Cuisine', activeCuisine != 'All', suffixText: activeCuisine != 'All' ? activeCuisine : null),
                  AppSizes.gapW8,
                  _buildFilterChip('Budget', activeBudget != 'All', suffixText: activeBudget != 'All' ? activeBudget : null),
                  AppSizes.gapW8,
                  _buildFilterChip('Rating', activeRating != null, suffixText: activeRating != null ? '${activeRating}+' : null),
                  AppSizes.gapW8,
                  _buildFilterChip('Wishlist-only', activeVisited == 'Wishlist-only'),
                ],
              ),
            ),
            AppSizes.gapH16,

            // Standard 4:3 card list scroll OR empty state
            Expanded(
              child: restaurants.isEmpty
                  ? GNEmptyState(
                      title: 'No Restaurants Yet',
                      subtitle: 'Save dining spots, bistros, and cafés to your dashboard.',
                      buttonLabel: 'Add Restaurant',
                      icon: Icons.restaurant_rounded,
                      onButtonPressed: () => context.push('/add-restaurant'),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
                      itemCount: restaurants.length,
                      separatorBuilder: (context, index) => AppSizes.gapH24,
                      itemBuilder: (context, index) {
                        final rest = restaurants[index];

                        return Column(
                          children: [
                            GNCard(
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
                            ),
                            AppSizes.gapH8,
                            // Inline tags row inside card footer bounds
                            Row(
                              children: [
                                GNChip(
                                  label: rest.category,
                                  variant: GNChipVariant.status,
                                  statusTone: GNStatusTone.info,
                                ),
                                AppSizes.gapW8,
                                GNChip(
                                  label: rest.budget,
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

class GNEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final IconData icon;

  const GNEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onButtonPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceFaint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.primary.withValues(alpha: 0.8)),
            ),
            AppSizes.gapH24,
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            AppSizes.gapH8,
            Text(
              subtitle,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            AppSizes.gapH24,
            SizedBox(
              width: 200,
              child: GNButton(
                label: buttonLabel,
                onPressed: onButtonPressed,
                variant: GNButtonVariant.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
