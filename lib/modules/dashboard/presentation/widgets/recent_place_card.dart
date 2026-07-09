import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

/// RecentPlaceCard renders a place preview for horizontal scrolling lists with refined visual design.
class RecentPlaceCard extends StatelessWidget {
  final String name;
  final String category;
  final double rating;
  final bool isWishlist;
  final IconData categoryIcon;

  const RecentPlaceCard({
    super.key,
    required this.name,
    required this.category,
    required this.rating,
    required this.isWishlist,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: AppSizes.shadowLevel2,
      ),
      padding: const EdgeInsets.all(AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceFaint,
                child: Icon(
                  categoryIcon,
                  color: AppColors.primary,
                  size: AppSizes.s16,
                ),
              ),
              Icon(
                isWishlist ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                color: isWishlist ? AppColors.error : AppColors.textSecondary,
                size: AppSizes.s20,
              ),
            ],
          ),
          AppSizes.gapH16,
          Text(
            name,
            style: AppTypography.bodyEmphasis.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSizes.gapH4,
          Text(
            category,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSizes.gapH12,
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: AppSizes.s16,
              ),
              AppSizes.gapW4,
              Text(
                rating.toStringAsFixed(1),
                style: AppTypography.bodyEmphasis.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
