import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/components/gn_card.dart';
import '../../../../shared/components/gn_chip.dart';

/// WishlistPage displays a motivational count title, toggleable list/map previews,
/// and list swipe-to-visit animations with premium photo coverage.
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  bool _isMapView = false;

  final List<Map<String, dynamic>> _mockWishlist = [
    {
      'name': 'Tulum Café',
      'category': 'Restaurant',
      'rating': 4.8,
      'savedTime': 'saved 3 weeks ago',
      'icon': Icons.restaurant_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Urban Threads',
      'category': 'Clothing Store',
      'rating': 4.2,
      'savedTime': 'saved 5 days ago',
      'icon': Icons.checkroom_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Grand Canyon',
      'category': 'Place to Visit',
      'rating': 4.9,
      'savedTime': 'saved 2 weeks ago',
      'icon': Icons.travel_explore_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Central Park NYC',
      'category': 'Place to Visit',
      'rating': 4.7,
      'savedTime': 'saved 1 month ago',
      'icon': Icons.eco_rounded,
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop&q=60',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                          '${_mockWishlist.length} places',
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
            AppSizes.gapH12,

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isMapView ? _buildMapView(context) : _buildListView(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a high-fidelity mock list with swipe-to-visited interactions
  Widget _buildListView(BuildContext context) {
    if (_mockWishlist.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.primary),
              AppSizes.gapH16,
              Text('Your wishlist is empty', style: AppTypography.title),
              AppSizes.gapH8,
              Text('Swipe, save, and keep places in mind.', style: AppTypography.caption),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, 120.0),
      itemCount: _mockWishlist.length,
      separatorBuilder: (context, index) => AppSizes.gapH24,
      itemBuilder: (context, index) {
        final item = _mockWishlist[index];

        return Dismissible(
          key: Key(item['name'] as String),
          direction: DismissDirection.startToEnd, // Swipe-right only
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: AppSizes.p24),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(AppSizes.r24),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: AppSizes.s28),
                AppSizes.gapW8,
                Text(
                  'Mark Visited',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              _mockWishlist.removeAt(index);
            });
            context.showSnackBar('Nice! Moved to Visits.', isError: false);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GNCard(
                variant: GNCardVariant.standard,
                title: item['name'] as String,
                subtitle: '${item['category']} • ${item['savedTime']}',
                rating: item['rating'] as double,
                isWishlist: true,
                icon: item['icon'] as IconData,
                imageUrl: item['imageUrl'] as String?,
                imageAspectRatio: 16 / 10,
              ),
              AppSizes.gapH8,
              // Footer metadata tag (saved time)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GNChip(
                    label: item['category'] as String,
                    variant: GNChipVariant.status,
                    statusTone: GNStatusTone.info,
                  ),
                  Text(
                    item['savedTime'] as String,
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

  /// Builds a high-fidelity visual map preview
  Widget _buildMapView(BuildContext context) {
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
          // Mock Map Grid lines
          CustomPaint(
            painter: MapMockPainter(),
          ),
          // Markers
          Positioned(
            top: 150,
            left: 120,
            child: _buildMockMarker(context, Icons.restaurant_rounded, 'Tulum Café'),
          ),
          Positioned(
            top: 250,
            right: 80,
            child: _buildMockMarker(context, Icons.checkroom_rounded, 'Urban Threads'),
          ),
          Positioned(
            bottom: 200,
            left: 90,
            child: _buildMockMarker(context, Icons.travel_explore_rounded, 'Grand Canyon'),
          ),
          // Map instruction header overlay
          Positioned(
            top: AppSizes.p16,
            left: AppSizes.p16,
            right: AppSizes.p16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppSizes.r16),
                boxShadow: AppSizes.shadowLevel2,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  AppSizes.gapW8,
                  Expanded(
                    child: Text(
                      'Wishlist places plotted near you.',
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

  Widget _buildMockMarker(BuildContext context, IconData icon, String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.p8),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: AppSizes.shadowLevel2,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

/// Custom painter to draw stylized map grid lines
class MapMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.7)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.height; i += 40.0) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    for (double i = 0; i < size.width; i += 40.0) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    final pathPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.08)
      ..strokeWidth = 32.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2,
        size.width,
        size.height * 0.7,
      );

    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
