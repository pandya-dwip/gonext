import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/gn_button.dart';

/// GNAddPlaceSheet is the redesigned premium category selection modal (Phase 4.3).
/// It lets the user select one of three categories with large selection cards and then proceed.
class GNAddPlaceSheet extends StatefulWidget {
  final ValueChanged<int> onCategorySelected;

  const GNAddPlaceSheet({
    super.key,
    required this.onCategorySelected,
  });

  @override
  State<GNAddPlaceSheet> createState() => _GNAddPlaceSheetState();
}

class _GNAddPlaceSheetState extends State<GNAddPlaceSheet> {
  int _selectedIndex = 0; // 0 = Restaurant, 1 = Clothing, 2 = Visit

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSizes.p24, AppSizes.p12, AppSizes.p24, AppSizes.p24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle and Close button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48), // Spacer to balance Close button
              // Center drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Top-right Close Button
              IconButton(
                icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          AppSizes.gapH12,

          // Header Title and Subtitle
          Text(
            'What would you like to add?',
            style: AppTypography.titleLarge.copyWith(fontSize: 24),
          ),
          AppSizes.gapH4,
          Text(
            'Choose a category to organize your new place.',
            style: AppTypography.caption,
          ),
          AppSizes.gapH24,

          // Selection Cards
          _buildSelectionCard(
            index: 0,
            icon: Icons.restaurant_rounded,
            title: 'Restaurant',
            description: 'Save your favourite restaurants, cafés and food places.',
          ),
          AppSizes.gapH12,
          _buildSelectionCard(
            index: 1,
            icon: Icons.storefront_rounded,
            title: 'Clothing Store',
            description: 'Remember fashion stores and shopping destinations.',
          ),
          AppSizes.gapH12,
          _buildSelectionCard(
            index: 2,
            icon: Icons.landscape_rounded,
            title: 'Place to Visit',
            description: 'Save tourist attractions and landmarks worth visiting.',
          ),
          AppSizes.gapH24,

          // Continue Button
          GNButton(
            label: 'Continue',
            fullWidth: true,
            variant: GNButtonVariant.primary,
            onPressed: () {
              Navigator.pop(context);
              widget.onCategorySelected(_selectedIndex);
            },
          ),
          // Buffer for bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected ? AppSizes.shadowLevel1 : null,
        ),
        child: Row(
          children: [
            // Left Section: icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceFaint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: AppSizes.s24,
              ),
            ),
            AppSizes.gapW16,

            // Center Section: Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyEmphasis.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            AppSizes.gapW16,

            // Right Section: indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
