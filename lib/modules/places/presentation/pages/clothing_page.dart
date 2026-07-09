import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_card.dart';
import '../../../../shared/components/gn_chip.dart';
import 'package:go_router/go_router.dart';

/// ClothingPage displays boutique streetwear and vintage collections
/// featuring a vertical card ratio (4:5 crop) with network lifestyle images.
class ClothingPage extends StatefulWidget {
  const ClothingPage({super.key});

  @override
  State<ClothingPage> createState() => _ClothingPageState();
}

class _ClothingPageState extends State<ClothingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All';

  final List<Map<String, dynamic>> _mockClothing = [
    {
      'name': 'Urban Threads',
      'type': 'Boutique Store',
      'budget': '₹₹',
      'rating': 4.3,
      'isWishlist': true,
      'imageUrl': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500&auto=format&fit=crop&q=60',
      'location': 'Linking Road, Bandra West, Mumbai',
    },
    {
      'name': 'Tokyo Streetwear',
      'type': 'Streetwear Hub',
      'budget': '₹₹₹',
      'rating': 4.6,
      'isWishlist': false,
      'imageUrl': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500&auto=format&fit=crop&q=60',
      'location': 'Colaba Causeway, South Mumbai',
    },
    {
      'name': 'Vogue Boutique',
      'type': 'Designer Atelier',
      'budget': '₹₹₹₹',
      'rating': 4.9,
      'isWishlist': true,
      'imageUrl': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=500&auto=format&fit=crop&q=60',
      'location': 'Palladium Mall, Lower Parel, Mumbai',
    },
    {
      'name': 'Retro Thrift',
      'type': 'Vintage/Thrift',
      'budget': '₹',
      'rating': 4.1,
      'isWishlist': false,
      'imageUrl': 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=500&auto=format&fit=crop&q=60',
      'location': 'Hill Road, Bandra West, Mumbai',
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
                    '${_mockClothing.length} saved boutiques',
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
                        decoration: InputDecoration(
                          hintText: 'Search stores, designers, tags...',
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

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  AppSizes.gapW8,
                  _buildFilterChip('Boutiques'),
                  AppSizes.gapW8,
                  _buildFilterChip('Thrift/Vintage'),
                  AppSizes.gapW8,
                  _buildFilterChip('Budget'),
                  AppSizes.gapW8,
                  _buildFilterChip('Rating'),
                ],
              ),
            ),
            AppSizes.gapH16,

            // 4:5 Card Scroll
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
                itemCount: _mockClothing.length,
                separatorBuilder: (context, index) => AppSizes.gapH24,
                itemBuilder: (context, index) {
                  final store = _mockClothing[index];

                  return Column(
                    children: [
                      GNCard(
                        variant: GNCardVariant.standard,
                        title: store['name'] as String,
                        subtitle: '${store['type']} • ${store['budget']}',
                        rating: store['rating'] as double,
                        isWishlist: store['isWishlist'] as bool,
                        icon: Icons.checkroom_rounded,
                        imageUrl: store['imageUrl'] as String?,
                        imageAspectRatio: 4 / 5, // Slightly taller 4:5 fashion crop
                        location: store['location'] as String?,
                        category: store['type'] as String?,
                        onTap: () => context.push('/clothing-detail/cloth-${index + 1}'),
                        onWishlistTap: () {
                          setState(() {
                            store['isWishlist'] = !(store['isWishlist'] as bool);
                          });
                        },
                      ),
                      AppSizes.gapH8,
                      Row(
                        children: [
                          GNChip(
                            label: store['type'] as String,
                            variant: GNChipVariant.status,
                            statusTone: GNStatusTone.info,
                            leadingIcon: Icons.style_rounded,
                          ),
                          AppSizes.gapW8,
                          GNChip(
                            label: store['budget'] as String,
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
