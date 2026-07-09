import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_typography.dart';

enum GNChipVariant {
  filter,
  category,
  status,
}

enum GNStatusTone {
  success,
  warning,
  error,
  info,
}

/// GNChip is a custom chip widget conforming to the specifications of Section 4.3.
class GNChip extends StatelessWidget {
  final GNChipVariant variant;
  final String label;
  final bool isSelected;
  final GNStatusTone? statusTone;
  final IconData? leadingIcon;
  final VoidCallback? onTap;

  const GNChip({
    super.key,
    required this.label,
    this.variant = GNChipVariant.filter,
    this.isSelected = false,
    this.statusTone,
    this.leadingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case GNChipVariant.filter:
        return _buildFilterChip(context);
      case GNChipVariant.category:
        return _buildCategoryChip(context);
      case GNChipVariant.status:
        return _buildStatusChip(context);
    }
  }

  // 1. Filter Chip: pill radius, 1.5px border, 36dp height.
  Widget _buildFilterChip(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.rPill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 16,
                color: isSelected ? AppColors.background : AppColors.textSecondary,
              ),
              AppSizes.gapW4,
            ],
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.background : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Category Chip: 44dp height, larger touch target
  Widget _buildCategoryChip(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceFaint,
          borderRadius: BorderRadius.circular(AppSizes.rPill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: AppSizes.s20,
                color: isSelected ? AppColors.background : AppColors.primary,
              ),
              AppSizes.gapW8,
            ],
            Text(
              label,
              style: AppTypography.bodyEmphasis.copyWith(
                color: isSelected ? AppColors.background : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Status Chip: small pill, 24dp height, filled Success/Warning/Error tone at 12% opacity with matching text
  Widget _buildStatusChip(BuildContext context) {
    Color baseColor;
    switch (statusTone ?? GNStatusTone.success) {
      case GNStatusTone.success:
        baseColor = AppColors.success;
        break;
      case GNStatusTone.warning:
        baseColor = AppColors.warning;
        break;
      case GNStatusTone.error:
        baseColor = AppColors.error;
        break;
      case GNStatusTone.info:
        baseColor = AppColors.secondary;
        break;
    }

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              size: 12,
              color: baseColor,
            ),
            AppSizes.gapW4,
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }
}
