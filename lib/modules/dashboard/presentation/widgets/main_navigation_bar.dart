import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/navigation_provider.dart';

/// MainNavigationBar implements the custom floating bottom navigation pill (Section 4.7).
/// It floats above the content with a backdrop blur, level 3 shadows, and five items.
class MainNavigationBar extends StatelessWidget {
  final DashboardTab selectedTab;
  final ValueChanged<DashboardTab> onTabSelected;

  const MainNavigationBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p16,
      ),
      child: ClipRRect(
        borderRadius: AppSizes.borderRadiusCircularPill,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.88),
              borderRadius: AppSizes.borderRadiusCircularPill,
              boxShadow: AppSizes.shadowLevel3,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                // Center Spacer for the overlapping FAB
                const SizedBox(width: 64),
                _buildNavItem(
                  context,
                  DashboardTab.visits,
                  Icons.travel_explore_rounded,
                  Icons.travel_explore_rounded, // travel_explore works as active/inactive
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
        ),
      ),
    );
  }

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
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
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
            if (isActive) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
