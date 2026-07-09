import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_card.dart';
import '../../../../shared/components/gn_chip.dart';

/// RestaurantsPage displays saved dining spots with search, chips filters,
/// and vertical 4:3 standard cards with network photography.
class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All';

  final List<Map<String, dynamic>> _mockRestaurants = [
    {
      'name': 'The Bombay Canteen',
      'cuisine': 'Modern Indian',
      'budget': '₹₹₹',
      'rating': 4.7,
      'isWishlist': false,
      'imageUrl': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Tulum Café',
      'cuisine': 'Mexican Bistro',
      'budget': '₹₹',
      'rating': 4.8,
      'isWishlist': true,
      'imageUrl': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500&auto=format&fit=crop&q=60',
    },
    {
      'name': 'The Green Olive',
      'cuisine': 'Mediterranean',
      'budget': '₹',
      'rating': 4.5,
      'isWishlist': false,
      'imageUrl': 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=500&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Bella Italia',
      'cuisine': 'Italian Pasta',
      'budget': '₹₹',
      'rating': 4.6,
      'isWishlist': true,
      'imageUrl': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&auto=format&fit=crop&q=60',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    '${_mockRestaurants.length} saved places',
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
                    const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
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
                  _buildFilterChip('All'),
                  AppSizes.gapW8,
                  _buildFilterChip('Cuisine'),
                  AppSizes.gapW8,
                  _buildFilterChip('Budget'),
                  AppSizes.gapW8,
                  _buildFilterChip('Rating'),
                  AppSizes.gapW8,
                  _buildFilterChip('Wishlist-only'),
                ],
              ),
            ),
            AppSizes.gapH16,

            // Standard 4:3 card list scroll
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
                itemCount: _mockRestaurants.length,
                separatorBuilder: (context, index) => AppSizes.gapH24,
                itemBuilder: (context, index) {
                  final rest = _mockRestaurants[index];

                  return Column(
                    children: [
                      GNCard(
                        variant: GNCardVariant.standard,
                        title: rest['name'] as String,
                        subtitle: '${rest['cuisine']} • ${rest['budget']}',
                        rating: rest['rating'] as double,
                        isWishlist: rest['isWishlist'] as bool,
                        icon: Icons.restaurant_rounded,
                        imageUrl: rest['imageUrl'] as String?,
                        imageAspectRatio: 4 / 3, // Standard M3 4:3 crop
                        onWishlistTap: () {
                          setState(() {
                            rest['isWishlist'] = !(rest['isWishlist'] as bool);
                          });
                        },
                      ),
                      AppSizes.gapH8,
                      // Inline tags row inside card footer bounds
                      Row(
                        children: [
                          GNChip(
                            label: rest['cuisine'] as String,
                            variant: GNChipVariant.status,
                            statusTone: GNStatusTone.info,
                          ),
                          AppSizes.gapW8,
                          GNChip(
                            label: rest['budget'] as String,
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

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return GNChip(
      label: label,
      variant: GNChipVariant.filter,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          _activeFilter = label;
        });
      },
    );
  }
}
