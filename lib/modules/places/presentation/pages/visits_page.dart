import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_card.dart';
import '../../../../shared/components/gn_chip.dart';

/// VisitsPage displays sightseeing nature and landmarks wishlists
/// utilizing wide 16:9 crop ratios resembling travel postcards.
class VisitsPage extends StatefulWidget {
  const VisitsPage({super.key});

  @override
  State<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All';

  final List<Map<String, dynamic>> _mockVisits = [
    {
      'name': 'Grand Canyon National Park',
      'type': 'Nature / Park',
      'price': 'Free',
      'season': 'Spring',
      'seasonIcon': Icons.wb_sunny_rounded,
      'rating': 4.9,
      'isWishlist': true,
      'imageUrl': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Taj Mahal Landmark',
      'type': 'Heritage / History',
      'price': '₹₹',
      'season': 'Winter',
      'seasonIcon': Icons.ac_unit_rounded,
      'rating': 4.8,
      'isWishlist': false,
      'imageUrl': 'https://images.unsplash.com/photo-1508849789987-4e5333c12b78?w=500&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Central Park NYC',
      'type': 'Nature / Walk',
      'price': 'Free',
      'season': 'Autumn',
      'seasonIcon': Icons.filter_hdr_rounded,
      'rating': 4.7,
      'isWishlist': true,
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Tomorrowland Resort',
      'type': 'Festival / Nightlife',
      'price': '₹₹₹₹',
      'season': 'Summer',
      'seasonIcon': Icons.beach_access_rounded,
      'rating': 4.9,
      'isWishlist': false,
      'imageUrl': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=500&auto=format&fit=crop&q=60',
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
                    'Places to Visit',
                    style: AppTypography.titleLarge.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_mockVisits.length} saved sights',
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
                          hintText: 'Search landmarks, seasons, fee...',
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
                  _buildFilterChip('Heritage'),
                  AppSizes.gapW8,
                  _buildFilterChip('Nature'),
                  AppSizes.gapW8,
                  _buildFilterChip('Free Entry'),
                  AppSizes.gapW8,
                  _buildFilterChip('Best Season'),
                ],
              ),
            ),
            AppSizes.gapH16,

            // 16:9 Card Scroll
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
                itemCount: _mockVisits.length,
                separatorBuilder: (context, index) => AppSizes.gapH24,
                itemBuilder: (context, index) {
                  final visit = _mockVisits[index];
                  final isFree = visit['price'] == 'Free';

                  return Column(
                    children: [
                      GNCard(
                        variant: GNCardVariant.standard,
                        title: visit['name'] as String,
                        subtitle: '${visit['type']} • Season: ${visit['season']}',
                        rating: visit['rating'] as double,
                        isWishlist: visit['isWishlist'] as bool,
                        icon: Icons.travel_explore_rounded,
                        imageUrl: visit['imageUrl'] as String?,
                        imageAspectRatio: 16 / 9, // Wide travel postcard crop
                        onWishlistTap: () {
                          setState(() {
                            visit['isWishlist'] = !(visit['isWishlist'] as bool);
                          });
                        },
                      ),
                      AppSizes.gapH8,
                      Row(
                        children: [
                          GNChip(
                            label: visit['type'] as String,
                            variant: GNChipVariant.status,
                            statusTone: GNStatusTone.info,
                          ),
                          AppSizes.gapW8,
                          GNChip(
                            label: visit['season'] as String,
                            variant: GNChipVariant.status,
                            statusTone: GNStatusTone.warning,
                            leadingIcon: visit['seasonIcon'] as IconData,
                          ),
                          AppSizes.gapW8,
                          GNChip(
                            label: visit['price'] as String,
                            variant: GNChipVariant.status,
                            statusTone: isFree ? GNStatusTone.success : GNStatusTone.info,
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
