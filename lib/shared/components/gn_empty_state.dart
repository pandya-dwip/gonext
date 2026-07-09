import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import 'gn_button.dart';

/// GNEmptyState implements the layout defined in Section 7 of the design system document.
/// It uses a single-color (Emerald) line-art icon, a primary title, caption-style subtext,
/// and an optional main action button.
class GNEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const GNEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p32, vertical: AppSizes.p64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Line-art illustration represented by an unshaded, clean stroked circular icon
            Container(
              padding: const EdgeInsets.all(AppSizes.p24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 72,
                color: AppColors.primary,
              ),
            ),
            AppSizes.gapH24,
            Text(
              title,
              style: AppTypography.title,
              textAlign: TextAlign.center,
            ),
            AppSizes.gapH8,
            Text(
              description,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              AppSizes.gapH24,
              GNButton(
                label: actionLabel!,
                onPressed: onActionPressed!,
                variant: GNButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
