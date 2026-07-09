import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_card.dart';
import '../../../../shared/components/gn_chip.dart';
import '../../data/models/place_model.dart';
import '../providers/place_provider.dart';
import 'restaurants_page.dart'; // Import GNEmptyState

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

  void _showFilterOptions(String filterType) {
    if (filterType == 'All') {
      ref.read(visitCategoryFilterProvider.notifier).state = 'All';
      ref.read(visitPriceFilterProvider.notifier).state = 'All';
      ref.read(visitVisitedFilterProvider.notifier).state = 'All';
      return;
    }

    if (filterType == 'Category') {
      final allPlaces = ref.read(placesListProvider).value ?? [];
      final categories = allPlaces
          .where((p) => p.type == 'visit')
          .map((p) => p.category)
          .toSet()
          .toList();
      categories.sort();

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Categories'),
                  onTap: () {
                    ref.read(visitCategoryFilterProvider.notifier).state = 'All';
                    Navigator.pop(context);
                  },
                ),
                ...categories.map((c) => ListTile(
                  title: Text(c),
                  onTap: () {
                    ref.read(visitCategoryFilterProvider.notifier).state = c;
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          );
        },
      );
    } else if (filterType == 'Entry Fee') {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('All Spots'),
                  onTap: () {
                    ref.read(visitPriceFilterProvider.notifier).state = 'All';
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Free Entry Only'),
                  onTap: () {
                    ref.read(visitPriceFilterProvider.notifier).state = 'Free';
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Paid Entry Only'),
                  onTap: () {
                    ref.read(visitPriceFilterProvider.notifier).state = 'Paid';
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else if (filterType == 'Wishlist-only') {
      final current = ref.read(visitVisitedFilterProvider);
      ref.read(visitVisitedFilterProvider.notifier).state =
          current == 'Wishlist-only' ? 'All' : 'Wishlist-only';
    }
  }

  @override
  Widget build(BuildContext context) {
    final visits = ref.watch(filteredVisitsProvider);

    final activeCategory = ref.watch(visitCategoryFilterProvider);
    final activePrice = ref.watch(visitPriceFilterProvider);
    final activeVisited = ref.watch(visitVisitedFilterProvider);

    final hasActiveFilter = activeCategory != 'All' ||
        activePrice != 'All' ||
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
                    const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
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
                  _buildFilterChip('Category', activeCategory != 'All', suffixText: activeCategory != 'All' ? activeCategory : null),
                  AppSizes.gapW8,
                  _buildFilterChip('Entry Fee', activePrice != 'All', suffixText: activePrice != 'All' ? activePrice : null),
                  AppSizes.gapW8,
                  _buildFilterChip('Wishlist-only', activeVisited == 'Wishlist-only'),
                ],
              ),
            ),
            AppSizes.gapH16,

            // Postcard 16:9 card list scroll OR empty state
            Expanded(
              child: visits.isEmpty
                  ? GNEmptyState(
                      title: 'No Places Yet',
                      subtitle: 'Save heritage sites, national parks, and viewpoints.',
                      buttonLabel: 'Add Travel Spot',
                      icon: Icons.travel_explore_rounded,
                      onButtonPressed: () => context.push('/add-visit'),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
                      itemCount: visits.length,
                      separatorBuilder: (context, index) => AppSizes.gapH24,
                      itemBuilder: (context, index) {
                        final place = visits[index];

                        return Column(
                          children: [
                            GNCard(
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
                            ),
                            AppSizes.gapH8,
                            Row(
                              children: [
                                GNChip(
                                  label: place.category,
                                  variant: GNChipVariant.status,
                                  statusTone: GNStatusTone.info,
                                ),
                                AppSizes.gapW8,
                                GNChip(
                                  label: place.bestTime ?? 'Winter',
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
