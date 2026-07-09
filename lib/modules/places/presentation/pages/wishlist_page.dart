import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_card.dart';
import '../../../../shared/components/gn_chip.dart';
import '../../../../shared/components/gn_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/place_provider.dart';
import '../../data/models/place_model.dart';
import '../../../../shared/components/gn_empty_state.dart';

/// WishlistPage displays a motivational count title, toggleable list/map previews,
/// and list swipe-to-visit animations with premium photo coverage.
class WishlistPage extends ConsumerStatefulWidget {
  const WishlistPage({super.key});

  @override
  ConsumerState<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends ConsumerState<WishlistPage> {
  bool _isMapView = false;
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

  void _navigateToDetail(BuildContext context, PlaceModel place) {
    if (place.type == 'restaurant') {
      context.push('/restaurant-detail/${place.id}');
    } else if (place.type == 'clothing') {
      context.push('/clothing-detail/${place.id}');
    } else {
      context.push('/place-detail/${place.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = ref.watch(filteredWishlistProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with motivational count Title Large
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${wishlist.length} places',
                          style: AppTypography.titleLarge.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'waiting for you to explore',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),

                  // List/Map toggle control
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceFaint,
                      borderRadius: BorderRadius.circular(AppSizes.rPill),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isMapView = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: !_isMapView ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSizes.rPill),
                            ),
                            child: Icon(
                              Icons.list_rounded,
                              size: 16,
                              color: !_isMapView ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isMapView = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isMapView ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSizes.rPill),
                            ),
                            child: Icon(
                              Icons.map_rounded,
                              size: 16,
                              color: _isMapView ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pinned Search Bar inside wishlist
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 4.0),
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
                          hintText: 'Search wishlist items...',
                          hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSizes.gapH12,

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isMapView ? _buildMapView(context, wishlist) : _buildListView(context, wishlist),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<PlaceModel> wishlist) {
    if (wishlist.isEmpty) {
      return const GNEmptyState(
        title: 'Your Wishlist is Empty',
        description: 'Add places and restaurants to keep them in mind for later.',
        actionLabel: 'Explore Dashboard',
        icon: Icons.favorite_border_rounded,
        onActionPressed: _noOp, // Handled inside GoRouter tab switch
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
      itemCount: wishlist.length,
      separatorBuilder: (context, index) => AppSizes.gapH24,
      itemBuilder: (context, index) {
        final item = wishlist[index];

        final aspect = item.type == 'restaurant'
            ? 4 / 3
            : item.type == 'clothing'
                ? 4 / 5
                : 16 / 9;

        final sub = item.type == 'visit'
            ? '${item.category} • ${item.entryFee ?? 'Free'}'
            : '${item.category} • ${item.budget}';

        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.startToEnd, // Swipe-right to mark as Visited!
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: AppSizes.p24),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(AppSizes.r24),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: AppSizes.s28),
                AppSizes.gapW8,
                Text(
                  'Mark Visited',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          onDismissed: (direction) async {
            final updated = PlaceModel(
              id: item.id,
              name: item.name,
              description: item.description,
              category: item.category,
              budget: item.budget,
              location: item.location,
              rating: item.rating,
              isVisited: true,
              isWishlist: false,
              imageUrl: item.imageUrl,
              type: item.type,
              entryFee: item.entryFee,
              bestTime: item.bestTime,
              latitude: item.latitude,
              longitude: item.longitude,
              dateAdded: item.dateAdded,
              lastUpdated: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
              imageType: item.imageType,
            );
            await ref.read(placesListProvider.notifier).updatePlace(updated);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Moved ${item.name} to Visits.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GNCard(
                variant: GNCardVariant.standard,
                title: item.name,
                subtitle: sub,
                rating: item.rating,
                isWishlist: true,
                icon: _getTypeIcon(item.type),
                imageUrl: item.imageUrl,
                imageType: item.imageType,
                imageAspectRatio: aspect,
                location: item.location,
                category: item.category,
                onTap: () => _navigateToDetail(context, item),
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
                    isWishlist: false, // remove from wishlist
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Added on ${item.dateAdded}',
                    style: AppTypography.caption.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapView(BuildContext context, List<PlaceModel> wishlist) {
    final hasMapKey = AppConstants.isMapsApiKeyValid;
    final mapItems = wishlist.where((p) => p.latitude != null && p.longitude != null).toList();

    if (hasMapKey && mapItems.isNotEmpty) {
      final markers = mapItems.map((p) {
        return Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.latitude!, p.longitude!),
          infoWindow: InfoWindow(
            title: p.name,
            snippet: _getTypeLabel(p.type),
            onTap: () => _navigateToDetail(context, p),
          ),
        );
      }).toSet();

      final initialPos = LatLng(mapItems.first.latitude!, mapItems.first.longitude!);

      return Container(
        margin: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceFaint,
          borderRadius: BorderRadius.circular(AppSizes.r24),
          border: Border.all(color: AppColors.border),
          boxShadow: AppSizes.shadowLevel1,
        ),
        clipBehavior: Clip.antiAlias,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: initialPos, zoom: 11),
          markers: markers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceFaint,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppSizes.shadowLevel1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: MapMockPainter(),
          ),
          ..._buildMockVisualMarkers(mapItems.isNotEmpty ? mapItems : wishlist),
          Positioned(
            top: AppSizes.p16,
            left: AppSizes.p16,
            right: AppSizes.p16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppSizes.r16),
                boxShadow: AppSizes.shadowLevel2,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  AppSizes.gapW8,
                  Expanded(
                    child: Text(
                      mapItems.isEmpty
                          ? 'No coordinates set for wishlist items.'
                          : 'Maps API key is missing. Visual plot fallback active.',
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMockVisualMarkers(List<PlaceModel> items) {
    if (items.isEmpty) return [];
    final positions = [
      const Point(150.0, 120.0),
      const Point(250.0, 200.0),
      const Point(100.0, 180.0),
      const Point(180.0, 80.0),
    ];
    final list = <Widget>[];
    for (int i = 0; i < items.length && i < positions.length; i++) {
      final item = items[i];
      final pos = positions[i];
      list.add(
        Positioned(
          top: pos.x,
          left: pos.y,
          child: GestureDetector(
            onTap: () => _navigateToDetail(context, item),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppSizes.shadowLevel1,
                  ),
                  child: Icon(_getTypeIcon(item.type), color: AppColors.primary, size: 18),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.name,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return list;
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'restaurant':
        return 'Restaurant';
      case 'clothing':
        return 'Clothing Store';
      default:
        return 'Place to Visit';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'clothing':
        return Icons.checkroom_rounded;
      default:
        return Icons.travel_explore_rounded;
    }
  }

  static void _noOp() {}
}

class Point {
  final double x;
  final double y;
  const Point(this.x, this.y);
}

class MapMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

