import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/navigation_provider.dart';

/// GNCurvedNavigationBar implements a premium Convex/Notched Bottom Navigation Bar (Phase 4.1).
/// It features a custom painter for smooth curves, a centered animated Home button,
/// and smooth transitions for item selection.
class GNCurvedNavigationBar extends StatelessWidget {
  final DashboardTab selectedTab;
  final ValueChanged<DashboardTab> onTabSelected;
  final VoidCallback? onHomeLongPress;

  const GNCurvedNavigationBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    this.onHomeLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const double barHeight = 72.0;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // 1. Custom Painted Navigation Bar Background (with shadow and notch)
        CustomPaint(
          size: Size(double.infinity, barHeight + bottomPadding),
          painter: CurvedNavigationBarPainter(),
        ),

        // 2. Navigation Row containing Left and Right items, leaving a center space
        Container(
          height: barHeight,
          margin: EdgeInsets.only(bottom: bottomPadding),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left Items
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      context,
                      DashboardTab.restaurants,
                      Icons.restaurant_outlined,
                      Icons.restaurant_rounded,
                      'Restaurants',
                    ),
                    _buildNavItem(
                      context,
                      DashboardTab.clothing,
                      Icons.checkroom_outlined,
                      Icons.checkroom_rounded,
                      'Clothing',
                    ),
                  ],
                ),
              ),

              // Empty spacer representing the notched Home gap in the row
              const SizedBox(width: 80),

              // Right Items
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      context,
                      DashboardTab.visits,
                      Icons.travel_explore_rounded,
                      Icons.travel_explore_rounded,
                      'Visits',
                    ),
                    _buildNavItem(
                      context,
                      DashboardTab.wishlist,
                      Icons.favorite_outline_rounded,
                      Icons.favorite_rounded,
                      'Wishlist',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. Floating Center Home Button (nestled in the notch)
        Positioned(
          bottom: bottomPadding + 20, // Nestles button overlapping the notch
          child: _buildHomeButton(),
        ),
      ],
    );
  }

  /// Builds the animated, circular Home button (Visual Anchor)
  Widget _buildHomeButton() {
    final isHomeActive = selectedTab == DashboardTab.home;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: isHomeActive ? 0.95 : 1.1,
        end: isHomeActive ? 1.1 : 0.95,
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => onTabSelected(DashboardTab.home),
            onLongPress: () {
              HapticFeedback.mediumImpact();
              if (onHomeLongPress != null) {
                onHomeLongPress!();
              }
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                boxShadow: isHomeActive ? AppSizes.shadowLevel3 : AppSizes.shadowLevel2,
                border: Border.all(
                  color: isHomeActive ? Colors.white : Colors.white.withValues(alpha: 0.8),
                  width: 2.5,
                ),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: AppSizes.s28,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds side item (Icon animates color and label opacity fades in)
  Widget _buildNavItem(
    BuildContext context,
    DashboardTab tab,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = selectedTab == tab;

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                size: AppSizes.s24,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive ? 1.0 : 0.0,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const SizedBox(height: 12), // Keep vertical alignment stable
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw a premium notched bottom bar.
class CurvedNavigationBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;

    // Build curve path
    final path = Path()
      ..moveTo(0, 20) // Slightly rounded top corners
      ..quadraticBezierTo(0, 0, 20, 0)
      ..lineTo(size.width / 2 - 44, 0)
      // Notch curve (smooth cubic bezier notch)
      ..cubicTo(
        size.width / 2 - 32, 0,
        size.width / 2 - 36, 32,
        size.width / 2, 32,
      )
      ..cubicTo(
        size.width / 2 + 36, 32,
        size.width / 2 + 32, 0,
        size.width / 2 + 44, 0,
      )
      ..lineTo(size.width - 20, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Paint shadow first
    canvas.drawShadow(path, AppColors.isDark ? const Color(0x3D000000) : const Color(0x1A0F5E45), 8.0, true);
    canvas.drawPath(path, paint);

    // Hairline top border
    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final borderPath = Path()
      ..moveTo(0, 20)
      ..quadraticBezierTo(0, 0, 20, 0)
      ..lineTo(size.width / 2 - 44, 0)
      ..cubicTo(
        size.width / 2 - 32, 0,
        size.width / 2 - 36, 32,
        size.width / 2, 32,
      )
      ..cubicTo(
        size.width / 2 + 36, 32,
        size.width / 2 + 32, 0,
        size.width / 2 + 44, 0,
      )
      ..lineTo(size.width - 20, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 20);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
