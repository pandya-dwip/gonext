import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_chip.dart';
import '../../data/models/mock_places.dart';
import '../../../../core/constants/app_constants.dart';
import 'wishlist_page.dart'; // import MapMockPainter for maps preview

/// RestaurantDetailPage displays detailed metadata for a dining spot.
class RestaurantDetailPage extends StatelessWidget {
  final String id;

  const RestaurantDetailPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final place = MockPlaces.getById(id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Immersive Hero sliver app bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Photo Loading
                  Image.network(
                    place.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceFaint,
                      child: const Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 48),
                    ),
                  ),
                  // Dark Gradients Scrim
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Title overlay in the bottom bounds
                  Positioned(
                    bottom: AppSizes.p24,
                    left: AppSizes.p24,
                    right: AppSizes.p24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GNChip(
                          label: place.category,
                          variant: GNChipVariant.status,
                          statusTone: GNStatusTone.info,
                        ),
                        AppSizes.gapH8,
                        Text(
                          place.name,
                          style: AppTypography.display.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable details listing
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(AppSizes.p24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating & Visited Metadata Row
                    Row(
                      children: [
                        // Rating Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                place.rating.toStringAsFixed(1),
                                style: AppTypography.bodyEmphasis.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSizes.gapW12,

                        // Visited Chip
                        GNChip(
                          label: place.isVisited ? 'Visited' : 'Wishlist',
                          variant: GNChipVariant.status,
                          statusTone: place.isVisited ? GNStatusTone.success : GNStatusTone.info,
                          leadingIcon: place.isVisited ? Icons.verified_rounded : Icons.bookmark_rounded,
                        ),
                      ],
                    ),
                    AppSizes.gapH24,

                    // Description Segment
                    Text('About'.toUpperCase(), style: AppTypography.overline),
                    AppSizes.gapH8,
                    Text(
                      place.description,
                      style: AppTypography.body.copyWith(height: 1.6),
                    ),
                    AppSizes.gapH32,

                    // Details Card Grid
                    Text('Information'.toUpperCase(), style: AppTypography.overline),
                    AppSizes.gapH12,
                    _buildInfoCard(
                      icon: Icons.restaurant_rounded,
                      title: 'Cuisine Style',
                      value: place.category,
                    ),
                    AppSizes.gapH12,
                    _buildInfoCard(
                      icon: Icons.payments_rounded,
                      title: 'Budget Range',
                      value: place.budget,
                    ),
                    AppSizes.gapH12,
                    _buildInfoCard(
                      icon: Icons.location_on_rounded,
                      title: 'Location / Address',
                      value: place.location,
                    ),
                    AppSizes.gapH32,

                    // Maps Preview Placeholder
                    Text('Location Map'.toUpperCase(), style: AppTypography.overline),
                    AppSizes.gapH12,
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceFaint,
                        borderRadius: BorderRadius.circular(AppSizes.r24),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomPaint(painter: MapMockPainter()),
                          if (AppConstants.isMapsApiKeyValid)
                            Center(
                              child: Icon(
                                Icons.location_on_rounded,
                                color: AppColors.error.withValues(alpha: 0.8),
                                size: 36,
                              ),
                            )
                          else
                            Container(
                              color: Colors.black.withValues(alpha: 0.6),
                              padding: const EdgeInsets.all(AppSizes.p16),
                              alignment: Alignment.center,
                              child: Text(
                                'Maps API key is missing. Live preview is disabled.',
                                style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                    AppSizes.gapH32,

                    // Footer timestamps
                    Divider(color: AppColors.border.withValues(alpha: 0.5)),
                    AppSizes.gapH12,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Added on ${place.dateAdded}', style: AppTypography.caption),
                        Text('Updated on ${place.lastUpdated}', style: AppTypography.caption),
                      ],
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFaint,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          AppSizes.gapW16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
