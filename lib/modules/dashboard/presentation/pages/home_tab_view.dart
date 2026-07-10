import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_card.dart';
import '../../../../shared/components/gn_chip.dart';
import '../../../../shared/components/gn_empty_state.dart';
import '../../../../shared/components/highlighted_text.dart';
import '../providers/navigation_provider.dart';
import '../../../places/data/models/place_model.dart';
import '../../../places/presentation/providers/place_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// HomeTabView implements the refined Phase 4.2 dashboard layout backed by Hive data.
class HomeTabView extends ConsumerStatefulWidget {
  const HomeTabView({super.key});

  @override
  ConsumerState<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends ConsumerState<HomeTabView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(homeSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(accentColorProvider);
    ref.watch(themeModeProvider);
    final placesAsync = ref.watch(placesListProvider);

    return placesAsync.when(
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (places) {
        if (places.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: GNEmptyState(
              icon: Icons.map_outlined,
              title: 'Your next favorite place starts here',
              description: 'Add a restaurant, boutique, or travel location to begin your travel diary.',
              actionLabel: 'Add your first place',
              onActionPressed: () {
                context.push('/add-restaurant');
              },
            ),
          );
        }

        final greeting = _getGreeting();
        final searchQuery = ref.watch(homeSearchQueryProvider);

        // Grouped Search Results View when query is entered
        if (searchQuery.isNotEmpty) {
          final groupedResults = ref.watch(groupedSearchResultsProvider);

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Header Area (Greeting + Settings Icon)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Search Results',
                                style: AppTypography.display.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.surfaceFaint,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.settings_rounded,
                              color: AppColors.textPrimary,
                              size: AppSizes.s24,
                            ),
                            onPressed: () => context.push('/settings'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.gapH16,

                  // Search Bar with clear/back button
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
                                ref.read(homeSearchQueryProvider.notifier).state = val;
                              },
                              decoration: InputDecoration(
                                hintText: 'Search across category, name, address...',
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
                            onTap: () {
                              _searchController.clear();
                              ref.read(homeSearchQueryProvider.notifier).state = '';
                            },
                            child: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSizes.gapH24,

                  // Results list or Empty State
                  Expanded(
                    child: groupedResults.isEmpty
                        ? GNEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No matches found',
                            description: 'No places match your search query "$searchQuery".',
                            actionLabel: 'Clear Search',
                            onActionPressed: () {
                              _searchController.clear();
                              ref.read(homeSearchQueryProvider.notifier).state = '';
                            },
                          )
                        : ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
                            children: [
                              _buildSearchResultCategorySection(
                                context,
                                ref,
                                'Restaurants',
                                groupedResults.restaurants,
                                searchQuery,
                              ),
                              _buildSearchResultCategorySection(
                                context,
                                ref,
                                'Clothing Stores',
                                groupedResults.clothing,
                                searchQuery,
                              ),
                              _buildSearchResultCategorySection(
                                context,
                                ref,
                                'Places to Visit',
                                groupedResults.visits,
                                searchQuery,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        }

        // Calculate statistics dynamically
        final savedCount = places.length;
        final visitedCount = places.where((p) => p.isVisited).length;
        
        final currentMonthStr = DateFormat('yyyy-MM').format(DateTime.now());
        final thisMonthCount = places.where((p) => p.dateAdded.startsWith(currentMonthStr)).length;

        // Categorize items and limit to 5
        final restaurants = places.where((p) => p.type == 'restaurant').toList();
        final clothing = places.where((p) => p.type == 'clothing').toList();
        final visits = places.where((p) => p.type == 'visit').toList();
        final wishlist = places.where((p) => p.isWishlist).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSizes.gapH24, // Top-of-screen breathing room

                  // 1. Collapsing App Bar Header Area (Greeting + Settings Icon)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting,',
                              style: AppTypography.display.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'explorer',
                              style: AppTypography.display.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.surfaceFaint,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.settings_rounded,
                            color: AppColors.textPrimary,
                            size: AppSizes.s24,
                          ),
                          onPressed: () => context.push('/settings'),
                        ),
                      ),
                    ],
                  ),
                  AppSizes.gapH24,

                  // 1.5 Home Search Bar
                  Container(
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
                              ref.read(homeSearchQueryProvider.notifier).state = val;
                            },
                            decoration: InputDecoration(
                              hintText: 'Search across category, name, address...',
                              hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              ref.read(homeSearchQueryProvider.notifier).state = '';
                            },
                            child: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                          ),
                      ],
                    ),
                  ),
                  AppSizes.gapH24,

                  // 2. Quick Actions row of 3 pill buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        GNChip(
                          label: 'Add Restaurant',
                          leadingIcon: Icons.restaurant_rounded,
                          variant: GNChipVariant.category,
                          onTap: () => context.push('/add-restaurant'),
                        ),
                        AppSizes.gapW8,
                        GNChip(
                          label: 'Add Clothing',
                          leadingIcon: Icons.checkroom_rounded,
                          variant: GNChipVariant.category,
                          onTap: () => context.push('/add-clothing'),
                        ),
                        AppSizes.gapW8,
                        GNChip(
                          label: 'Add Visit',
                          leadingIcon: Icons.travel_explore_rounded,
                          variant: GNChipVariant.category,
                          onTap: () => context.push('/add-visit'),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.gapH32,

                  // 4. Statistics Row
                  Row(
                    children: [
                      Expanded(
                        child: GNCard(
                          variant: GNCardVariant.stat,
                          value: savedCount.toString(),
                          title: 'Saved',
                          icon: Icons.bookmark_added_rounded,
                        ),
                      ),
                      AppSizes.gapW12,
                      Expanded(
                        child: GNCard(
                          variant: GNCardVariant.stat,
                          value: visitedCount.toString(),
                          title: 'Visited',
                          icon: Icons.verified_rounded,
                        ),
                      ),
                      AppSizes.gapW12,
                      Expanded(
                        child: GNCard(
                          variant: GNCardVariant.stat,
                          value: thisMonthCount.toString(),
                          title: 'This Month',
                          icon: Icons.calendar_month_rounded,
                        ),
                      ),
                    ],
                  ),
                  AppSizes.gapH32,

                  // 6. Previews
                  // A. Restaurants Preview
                  _buildSectionHeader(
                    context,
                    title: 'Recently Added Restaurants',
                    overline: 'RESTAURANTS',
                    indicatorIcon: Icons.restaurant_rounded,
                    indicatorColor: AppColors.primary,
                    onSeeAllPressed: () {
                      ref.read(dashboardTabProvider.notifier).setTab(DashboardTab.restaurants);
                    },
                  ),
                  if (restaurants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No restaurants saved yet.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: restaurants.length > 5 ? 5 : restaurants.length,
                        itemBuilder: (context, idx) {
                          final rest = restaurants[idx];
                          return GNCard(
                            variant: GNCardVariant.compact,
                            title: rest.name,
                            subtitle: '${rest.category} • ${rest.budget}',
                            icon: Icons.restaurant_rounded,
                            imageUrl: rest.imageUrl,
                            imageType: rest.imageType,
                            onTap: () => context.push('/restaurant-detail/${rest.id}'),
                          );
                        },
                      ),
                    ),
                  AppSizes.gapH24,

                  // B. Clothing Stores Preview
                  _buildSectionHeader(
                    context,
                    title: 'Recently Added Boutiques',
                    overline: 'CLOTHING STORES',
                    indicatorIcon: Icons.checkroom_rounded,
                    indicatorColor: AppColors.secondary,
                    onSeeAllPressed: () {
                      ref.read(dashboardTabProvider.notifier).setTab(DashboardTab.clothing);
                    },
                  ),
                  if (clothing.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No boutiques saved yet.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: clothing.length > 5 ? 5 : clothing.length,
                        itemBuilder: (context, idx) {
                          final store = clothing[idx];
                          return GNCard(
                            variant: GNCardVariant.compact,
                            title: store.name,
                            subtitle: '${store.category} • ${store.budget}',
                            icon: Icons.checkroom_rounded,
                            imageUrl: store.imageUrl,
                            imageType: store.imageType,
                            onTap: () => context.push('/clothing-detail/${store.id}'),
                          );
                        },
                      ),
                    ),
                  AppSizes.gapH24,

                  // C. Places to Visit Preview
                  _buildSectionHeader(
                    context,
                    title: 'Recently Added Landmarks',
                    overline: 'PLACES TO VISIT',
                    indicatorIcon: Icons.travel_explore_rounded,
                    indicatorColor: AppColors.warning,
                    onSeeAllPressed: () {
                      ref.read(dashboardTabProvider.notifier).setTab(DashboardTab.visits);
                    },
                  ),
                  if (visits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No travel spots saved yet.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: visits.length > 5 ? 5 : visits.length,
                        itemBuilder: (context, idx) {
                          final place = visits[idx];
                          return GNCard(
                            variant: GNCardVariant.compact,
                            title: place.name,
                            subtitle: '${place.category} • ${place.entryFee ?? 'Free'}',
                            icon: Icons.travel_explore_rounded,
                            imageUrl: place.imageUrl,
                            imageType: place.imageType,
                            onTap: () => context.push('/place-detail/${place.id}'),
                          );
                        },
                      ),
                    ),
                  AppSizes.gapH24,

                  // 8. Wishlist preview
                  _buildSectionHeader(
                    context,
                    title: 'Wishlist preview',
                    overline: 'WISHLIST PREVIEW',
                    onSeeAllPressed: () {
                      ref.read(dashboardTabProvider.notifier).setTab(DashboardTab.wishlist);
                    },
                  ),
                  _buildWishlistPreview(context, ref, wishlist),
                  AppSizes.gapH32,

                  // Extra padding for bottom bar
                  AppSizes.gapH64,
                  AppSizes.gapH48,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a section header with an uppercase eyebrow label, optional leading accent icon, and optional "See all" button
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String overline,
    IconData? indicatorIcon,
    Color? indicatorColor,
    VoidCallback? onSeeAllPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          overline,
          style: AppTypography.overline,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (indicatorIcon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: (indicatorColor ?? AppColors.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        indicatorIcon,
                        size: 16,
                        color: indicatorColor ?? AppColors.primary,
                      ),
                    ),
                    AppSizes.gapW8,
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.title.copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (onSeeAllPressed != null)
              TextButton(
                onPressed: onSeeAllPressed,
                child: Text(
                  'See all',
                  style: AppTypography.bodyEmphasis.copyWith(color: AppColors.primary),
                ),
              ),
          ],
        ),
        AppSizes.gapH12,
      ],
    );
  }

  /// Builds the 2x2 Grid of Wishlist preview tiles (with +N overlay on the 4th item)
  Widget _buildWishlistPreview(BuildContext context, WidgetRef ref, List<PlaceModel> wishlist) {
    if (wishlist.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text('No wishlist items saved yet.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final displayCount = wishlist.length > 4 ? 4 : wishlist.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSizes.p12,
        crossAxisSpacing: AppSizes.p12,
        childAspectRatio: 1.2,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        final item = wishlist[index];
        final isLast = index == 3 && wishlist.length > 4;

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {
                  if (item.type == 'restaurant') {
                    context.push('/restaurant-detail/${item.id}');
                  } else if (item.type == 'clothing') {
                    context.push('/clothing-detail/${item.id}');
                  } else {
                    context.push('/place-detail/${item.id}');
                  }
                },
                child: Container(
                  color: AppColors.surfaceFaint,
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        item.type == 'restaurant'
                            ? Icons.restaurant_rounded
                            : item.type == 'clothing'
                                ? Icons.checkroom_rounded
                                : Icons.travel_explore_rounded,
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      Text(
                        item.name,
                        style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (isLast)
                GestureDetector(
                  onTap: () {
                    ref.read(dashboardTabProvider.notifier).setTab(DashboardTab.wishlist);
                  },
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    alignment: Alignment.center,
                    child: Text(
                      '+${wishlist.length - 3} more',
                      style: AppTypography.subtitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Helper to build category sections in search results
  Widget _buildSearchResultCategorySection(
    BuildContext context,
    WidgetRef ref,
    String categoryName,
    List<PlaceModel> list,
    String searchQuery,
  ) {
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            categoryName.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppColors.primary),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (context, idx) => AppSizes.gapH16,
          itemBuilder: (context, idx) {
            final item = list[idx];
            return GNCard(
              variant: GNCardVariant.standard,
              title: item.name,
              subtitle: '${item.category} • ${item.budget}',
              imageUrl: item.imageUrl,
              imageType: item.imageType,
              rating: item.rating,
              isWishlist: item.isWishlist,
              location: item.location,
              category: item.category,
              titleWidget: HighlightedText(
                text: item.name,
                query: searchQuery,
                style: AppTypography.titleLarge.copyWith(fontSize: 18, color: AppColors.textPrimary),
              ),
              subtitleWidget: HighlightedText(
                text: '${item.category} • ${item.budget}',
                query: searchQuery,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              locationWidget: HighlightedText(
                text: item.location,
                query: searchQuery,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
              onTap: () {
                if (item.type == 'restaurant') {
                  context.push('/restaurant-detail/${item.id}');
                } else if (item.type == 'clothing') {
                  context.push('/clothing-detail/${item.id}');
                } else {
                  context.push('/place-detail/${item.id}');
                }
              },
              onWishlistTap: () async {
                final updated = PlaceModel(
                  id: item.id,
                  name: item.name,
                  description: item.description,
                  category: item.category,
                  budget: item.budget,
                  location: item.location,
                  rating: item.rating,
                  isVisited: item.isVisited,
                  isWishlist: !item.isWishlist,
                  imageUrl: item.imageUrl,
                  type: item.type,
                  entryFee: item.entryFee,
                  bestTime: item.bestTime,
                  latitude: item.latitude,
                  longitude: item.longitude,
                  dateAdded: item.dateAdded,
                  lastUpdated: item.lastUpdated,
                  imageType: item.imageType,
                );
                await ref.read(placesListProvider.notifier).updatePlace(updated);
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
