import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_chip.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/place_provider.dart';
import 'wishlist_page.dart'; // import MapMockPainter for maps preview

/// PlaceDetailPage displays detailed attributes for travel and sightseeing landmarks.
class PlaceDetailPage extends ConsumerWidget {
  final String id;

  const PlaceDetailPage({
    super.key,
    required this.id,
  });

  void _confirmDelete(BuildContext context, WidgetRef ref, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Place?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Pop dialog
                await ref.read(placesListProvider.notifier).deletePlace(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$name deleted successfully.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context); // Pop detail page
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailImage(String type, String path) {
    if (type == 'file') {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      } else {
        return Container(
          color: AppColors.surfaceFaint,
          child: const Center(
            child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 48),
          ),
        );
      }
    } else if (type == 'asset') {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
        return Container(color: AppColors.surfaceFaint);
      });
    } else {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
        return Container(color: AppColors.surfaceFaint);
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placesListProvider);

    return placesAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (places) {
        final matches = places.where((p) => p.id == id).toList();
        if (matches.isEmpty) {
          return const Scaffold(body: Center(child: Text('Place not found.')));
        }
        final place = matches.first;
        final bool hasMapKey = AppConstants.isMapsApiKeyValid;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Cover sliver
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
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      child: IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                        onPressed: () => context.push('/add-visit?id=${place.id}'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      child: IconButton(
                        icon: const Icon(Icons.delete_rounded, color: Colors.white, size: 18),
                        onPressed: () => _confirmDelete(context, ref, place.name),
                      ),
                    ),
                  ),
                ],
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildDetailImage(place.imageType, place.imageUrl),
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

              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.p24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Row
                        Row(
                          children: [
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
                            GNChip(
                              label: place.isVisited ? 'Visited' : 'Wishlist',
                              variant: GNChipVariant.status,
                              statusTone: place.isVisited ? GNStatusTone.success : GNStatusTone.info,
                              leadingIcon: place.isVisited ? Icons.verified_rounded : Icons.bookmark_rounded,
                            ),
                          ],
                        ),
                        AppSizes.gapH24,

                        Text('Description'.toUpperCase(), style: AppTypography.overline),
                        AppSizes.gapH8,
                        Text(
                          place.description,
                          style: AppTypography.body.copyWith(height: 1.6),
                        ),
                        AppSizes.gapH32,

                        Text('Information'.toUpperCase(), style: AppTypography.overline),
                        AppSizes.gapH12,
                        _buildInfoCard(
                          icon: Icons.category_rounded,
                          title: 'Category',
                          value: place.category,
                        ),
                        AppSizes.gapH12,
                        _buildInfoCard(
                          icon: Icons.payments_rounded,
                          title: 'Entry Fee',
                          value: place.entryFee ?? 'Free',
                        ),
                        AppSizes.gapH12,
                        _buildInfoCard(
                          icon: Icons.wb_sunny_rounded,
                          title: 'Best Season',
                          value: place.bestTime ?? 'Winter',
                        ),
                        AppSizes.gapH12,
                        _buildInfoCard(
                          icon: Icons.location_on_rounded,
                          title: 'Location / Address',
                          value: place.location,
                        ),
                        AppSizes.gapH32,

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
                              if (hasMapKey && place.latitude != null && place.longitude != null)
                                AbsorbPointer(
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(place.latitude!, place.longitude!),
                                      zoom: 14,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId('detail-loc'),
                                        position: LatLng(place.latitude!, place.longitude!),
                                      ),
                                    },
                                    zoomControlsEnabled: false,
                                    myLocationButtonEnabled: false,
                                  ),
                                )
                              else ...[
                                CustomPaint(painter: MapMockPainter()),
                                if (place.latitude != null && place.longitude != null)
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    padding: const EdgeInsets.all(AppSizes.p16),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.map_rounded, color: Colors.white, size: 24),
                                        AppSizes.gapH4,
                                        Text(
                                          'Maps API key is missing. Live preview is disabled.',
                                          style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 11),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        AppSizes.gapH32,

                        Divider(color: AppColors.border.withValues(alpha: 0.5)),
                        AppSizes.gapH12,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('Added on ${place.dateAdded}', style: AppTypography.caption),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Updated on ${place.lastUpdated}',
                                style: AppTypography.caption,
                                textAlign: TextAlign.end,
                              ),
                            ),
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
      },
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
