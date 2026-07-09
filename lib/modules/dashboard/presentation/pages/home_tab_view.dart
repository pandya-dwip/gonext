import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_card.dart';
import '../../../../shared/components/gn_chip.dart';
import '../../../../shared/components/gn_empty_state.dart';
import '../providers/navigation_provider.dart';

/// HomeTabView implements the refined Phase 4.2 dashboard layout.
class HomeTabView extends ConsumerWidget {
  final bool isEmpty;

  const HomeTabView({
    super.key,
    this.isEmpty = false,
  });

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
  Widget build(BuildContext context, WidgetRef ref) {
    if (isEmpty) {
      return GNEmptyState(
        icon: Icons.map_outlined,
        title: 'Your next favorite place starts here',
        description: 'Add a restaurant, boutique, or travel location to begin your travel diary.',
        actionLabel: 'Add your first place',
        onActionPressed: () {},
      );
    }

    final greeting = _getGreeting();

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
                      icon: const Icon(
                        Icons.settings_rounded,
                        color: AppColors.textPrimary,
                        size: AppSizes.s24,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
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
                      onTap: () {},
                    ),
                    AppSizes.gapW8,
                    GNChip(
                      label: 'Add Clothing',
                      leadingIcon: Icons.checkroom_rounded,
                      variant: GNChipVariant.category,
                      onTap: () {},
                    ),
                    AppSizes.gapW8,
                    GNChip(
                      label: 'Add Visit',
                      leadingIcon: Icons.travel_explore_rounded,
                      variant: GNChipVariant.category,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              AppSizes.gapH32,

              // 3. [COMMENTED OUT] Today's Inspiration
              /*
              Text(
                'TODAY\'S INSPIRATION',
                style: AppTypography.overline,
              ),
              AppSizes.gapH8,
              const GNCard(
                variant: GNCardVariant.hero,
                overline: 'HAVE YOU BEEN HERE YET?',
                title: 'The Bombay Canteen',
                icon: Icons.restaurant_rounded,
              ),
              AppSizes.gapH32,
              */

              // 4. Statistics Row
              Row(
                children: const [
                  Expanded(
                    child: GNCard(
                      variant: GNCardVariant.stat,
                      value: '12',
                      title: 'Saved',
                      icon: Icons.bookmark_added_rounded,
                    ),
                  ),
                  AppSizes.gapW12,
                  Expanded(
                    child: GNCard(
                      variant: GNCardVariant.stat,
                      value: '5',
                      title: 'Visited',
                      icon: Icons.verified_rounded,
                    ),
                  ),
                  AppSizes.gapW12,
                  Expanded(
                    child: GNCard(
                      variant: GNCardVariant.stat,
                      value: '3',
                      title: 'This Month',
                      icon: Icons.calendar_month_rounded,
                    ),
                  ),
                ],
              ),
              AppSizes.gapH32,

              // 5. [COMMENTED OUT] Continue exploring
              /*
              _buildSectionHeader(
                context,
                title: 'Continue exploring',
                overline: 'CONTINUE EXPLORING',
                onSeeAllPressed: () {},
              ),
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Tulum Café',
                      subtitle: 'Restaurant',
                      isWishlist: true,
                      icon: Icons.restaurant_rounded,
                    ),
                    ...
                  ],
                ),
              ),
              AppSizes.gapH24,
              */

              // 6. Section 5 Replacement: Category-Specific Previews

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
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'The Bombay Canteen',
                      subtitle: 'Modern Indian • ₹₹₹',
                      icon: Icons.restaurant_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Tulum Café',
                      subtitle: 'Mexican Bistro • ₹₹',
                      isWishlist: true,
                      icon: Icons.restaurant_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'The Green Olive',
                      subtitle: 'Mediterranean • ₹',
                      icon: Icons.restaurant_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Bella Italia',
                      subtitle: 'Italian Bistro • ₹₹',
                      icon: Icons.restaurant_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Baker\'s Pride',
                      subtitle: 'Bakery • ₹',
                      icon: Icons.restaurant_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=60',
                    ),
                  ],
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
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Urban Threads',
                      subtitle: 'Streetwear Hub • ₹₹',
                      isWishlist: true,
                      icon: Icons.checkroom_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Tokyo Streetwear',
                      subtitle: 'Boutique Store • ₹₹₹',
                      icon: Icons.checkroom_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Vogue Boutique',
                      subtitle: 'Designer Atelier • ₹₹₹₹',
                      icon: Icons.checkroom_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Retro Vintage',
                      subtitle: 'Thrift Store • ₹',
                      icon: Icons.checkroom_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Concept Atelier',
                      subtitle: 'Designer Collective • ₹₹₹',
                      icon: Icons.checkroom_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1567401893930-7db7138b315d?w=500&auto=format&fit=crop&q=60',
                    ),
                  ],
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
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Grand Canyon',
                      subtitle: 'Nature Reserve • Free',
                      isWishlist: true,
                      icon: Icons.travel_explore_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Taj Mahal',
                      subtitle: 'Historical Site • ₹₹',
                      icon: Icons.travel_explore_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1508849789987-4e5333c12b78?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Central Park NYC',
                      subtitle: 'City Landmark • Free',
                      icon: Icons.travel_explore_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Kyoto Temple',
                      subtitle: 'Heritage Gardens • ₹',
                      icon: Icons.travel_explore_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=500&auto=format&fit=crop&q=60',
                    ),
                    GNCard(
                      variant: GNCardVariant.compact,
                      title: 'Tomorrowland Resort',
                      subtitle: 'Amusement Hub • ₹₹₹₹',
                      icon: Icons.travel_explore_rounded,
                      imageUrl: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=500&auto=format&fit=crop&q=60',
                    ),
                  ],
                ),
              ),
              AppSizes.gapH24,

              // 7. [COMMENTED OUT] Smart suggestions
              /*
              _buildSectionHeader(context, title: 'Smart suggestions', overline: 'SMART SUGGESTIONS'),
              const GNCard(
                variant: GNCardVariant.standard,
                title: '3 cafes near places you\'ve visited',
                subtitle: 'Based on your recent checks in Manhattan area.',
                rating: 4.8,
                icon: Icons.eco_rounded,
              ),
              AppSizes.gapH32,
              */

              // 8. Wishlist preview
              _buildSectionHeader(
                context,
                title: 'Wishlist preview',
                overline: 'WISHLIST PREVIEW',
                onSeeAllPressed: () {
                  ref.read(dashboardTabProvider.notifier).setTab(DashboardTab.wishlist);
                },
              ),
              _buildWishlistPreview(ref),
              AppSizes.gapH32,

              // 9. [REMOVED] Recent activity
              /*
              _buildSectionHeader(context, title: 'Recent activity', overline: 'RECENT ACTIVITY'),
              _buildRecentActivityList(),
              */

              // Extra padding for bottom bar
              AppSizes.gapH64,
              AppSizes.gapH48,
            ],
          ),
        ),
      ),
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
  Widget _buildWishlistPreview(WidgetRef ref) {
    final previewItems = [
      {'name': 'Tulum Cafe', 'icon': Icons.restaurant_rounded},
      {'name': 'Tokyo Boutique', 'icon': Icons.checkroom_rounded},
      {'name': 'Costa del Sol', 'icon': Icons.travel_explore_rounded},
      {'name': 'Grand Canyon', 'icon': Icons.eco_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSizes.p12,
        crossAxisSpacing: AppSizes.p12,
        childAspectRatio: 1.2,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final item = previewItems[index];
        final isLast = index == 3;

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: AppColors.surfaceFaint,
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(item['icon'] as IconData, color: AppColors.primary.withValues(alpha: 0.4)),
                    Text(
                      item['name'] as String,
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                      '+12 more',
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
}
