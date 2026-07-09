import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/constants/app_sizes.dart';

/// RecentPlaceCard renders a place preview for horizontal scrolling lists.
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
        color: context.colors.surface,
        borderRadius: AppSizes.borderRadiusCircular16,
        border: Border.all(color: context.colors.outlineVariant),
        boxShadow: AppSizes.softShadow,
      ),
      padding: const EdgeInsets.all(AppSizes.p12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: context.colors.primaryContainer,
                child: Icon(
                  categoryIcon,
                  color: context.colors.primary,
                  size: AppSizes.s16,
                ),
              ),
              Icon(
                isWishlist ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                color: isWishlist ? context.colors.error : context.colors.onSurfaceVariant,
                size: AppSizes.s20,
              ),
            ],
          ),
          AppSizes.gapH12,
          Text(
            name,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSizes.gapH4,
          Text(
            category,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSizes.gapH8,
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
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
