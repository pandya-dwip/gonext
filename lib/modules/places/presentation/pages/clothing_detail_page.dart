import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_chip.dart';
import '../../../../shared/components/gn_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/place_provider.dart';
import 'wishlist_page.dart'; // import MapMockPainter for maps preview
import '../../../../core/theme/map_theme.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// ClothingDetailPage displays detailed properties of boutique retail locations.
class ClothingDetailPage extends ConsumerWidget {
  final String id;

  const ClothingDetailPage({
    super.key,
    required this.id,
  });

  void _confirmDelete(BuildContext context, WidgetRef ref, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Clothing Store?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // close dialog
                context.pop(); // back to listings
                await ref.read(placesListProvider.notifier).deletePlace(id);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _openMapOptions(BuildContext context, String name, double lat, double lng) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSizes.gapH24,
                Text(
                  'Open in Maps',
                  style: AppTypography.title.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose how you would like to view or navigate to $name.',
                  style: AppTypography.caption,
                ),
                AppSizes.gapH24,
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.map_rounded, color: AppColors.primary),
                  ),
                  title: Text('Google Maps', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('View location on map', style: AppTypography.caption),
                  onTap: () async {
                    Navigator.pop(context);
                    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                    try {
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to open maps.')),
                      );
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.navigation_rounded, color: AppColors.primary),
                  ),
                  title: Text('Google Maps Navigation', style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('Get directions to this place', style: AppTypography.caption),
                  onTap: () async {
                    Navigator.pop(context);
                    final url = Uri.parse('google.navigation:q=$lat,$lng');
                    final fallbackUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                    try {
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else if (await canLaunchUrl(fallbackUrl)) {
                        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
                      }
                    } catch (_) {
                      if (await canLaunchUrl(fallbackUrl)) {
                        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                ),
                AppSizes.gapH24,
                SizedBox(
                  width: double.infinity,
                  child: GNButton(
                    label: 'Cancel',
                    variant: GNButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
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
          child: Center(
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
    ref.watch(accentColorProvider);
    ref.watch(themeModeProvider);
    final placesAsync = ref.watch(placesListProvider);

    return placesAsync.when(
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (places) {
        final matches = places.where((p) => p.id == id).toList();
        if (matches.isEmpty) {
          return const Scaffold(body: Center(child: Text('Store not found.')));
        }
        final place = matches.first;
        final bool hasMapKey = AppConstants.isMapsApiKeyValid;

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
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      child: IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                        onPressed: () => context.push('/add-clothing?id=${place.id}'),
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
                        // SECTION 1: General Information
                        _buildSectionHeader(icon: Icons.checkroom_rounded, title: 'General Information'),
                        _buildInfoCard(
                          icon: Icons.store_rounded,
                          title: 'Store Type',
                          value: place.category,
                        ),
                        AppSizes.gapH12,
                        _buildInfoCard(
                          icon: Icons.payments_rounded,
                          title: 'Budget Range',
                          value: place.budget,
                        ),
                        AppSizes.gapH16,
                        Text('Description', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                        AppSizes.gapH8,
                        Text(
                          place.description,
                          style: AppTypography.body.copyWith(height: 1.6),
                        ),
                        AppSizes.gapH32,

                        // SECTION 2: Ratings & Wishlist
                        _buildSectionHeader(icon: Icons.star_rounded, title: 'Ratings & Wishlist'),
                        Container(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceFaint,
                            borderRadius: BorderRadius.circular(AppSizes.r16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Average Rating', style: AppTypography.caption),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.orange, size: 24),
                                      const SizedBox(width: 6),
                                      Text(
                                        place.rating.toStringAsFixed(1),
                                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Status', style: AppTypography.caption),
                                  const SizedBox(height: 4),
                                  GNChip(
                                    label: place.isVisited ? 'Visited' : 'Wishlist',
                                    variant: GNChipVariant.status,
                                    statusTone: place.isVisited ? GNStatusTone.success : GNStatusTone.info,
                                    leadingIcon: place.isVisited ? Icons.verified_rounded : Icons.bookmark_rounded,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppSizes.gapH32,

                        // SECTION 3: Location Details
                        _buildSectionHeader(icon: Icons.location_on_rounded, title: 'Location Details'),
                        _buildInfoCard(
                          icon: Icons.map_outlined,
                          title: 'Address',
                          value: place.location,
                        ),
                        AppSizes.gapH12,
                        if (place.latitude != null && place.longitude != null) ...[
                          _buildInfoCard(
                            icon: Icons.gps_fixed_rounded,
                            title: 'Coordinates',
                            value: '${place.latitude!.toStringAsFixed(6)}, ${place.longitude!.toStringAsFixed(6)}',
                          ),
                          AppSizes.gapH16,
                        ],
                        GestureDetector(
                          onTap: () {
                            if (place.latitude != null && place.longitude != null) {
                              _openMapOptions(context, place.name, place.latitude!, place.longitude!);
                            }
                          },
                          child: Container(
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
                                      onMapCreated: (controller) {
                                        MapTheme.applyMapStyle(controller, AppColors.isDark);
                                      },
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
                                            'Maps API key is missing. Tap to view options.',
                                            style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 11),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      padding: const EdgeInsets.all(AppSizes.p16),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.location_off_rounded, color: Colors.white, size: 24),
                                          AppSizes.gapH4,
                                          Text(
                                            'No coordinates provided for this location.',
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
                        ),
                        AppSizes.gapH32,

                        // SECTION 4: Audit Information
                        _buildSectionHeader(icon: Icons.history_rounded, title: 'Audit Information'),
                        Container(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceFaint,
                            borderRadius: BorderRadius.circular(AppSizes.r16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildAuditRow('Created On', place.dateAdded),
                              const Divider(height: 16),
                              _buildAuditRow('Updated On', place.lastUpdated.split(' ').first),
                              const Divider(height: 16),
                              _buildAuditRow('Created By', place.isDemoData ? 'Demo System' : 'User (You)'),
                              const Divider(height: 16),
                              _buildAuditRow('Last Modified', place.lastUpdated),
                            ],
                          ),
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

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: AppTypography.overline.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAuditRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption),
        Text(value, style: AppTypography.bodyEmphasis.copyWith(fontWeight: FontWeight.bold)),
      ],
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
