import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_typography.dart';

enum GNCardVariant {
  standard,
  hero,
  compact,
  stat,
}

/// GNCard is a premium card component conforming to the visual specifications.
/// It displays external network photography when [imageUrl] is provided.
class GNCard extends StatelessWidget {
  final GNCardVariant variant;
  final String title;
  final String? subtitle;
  final String? overline;
  final String? value; // For stat cards
  final IconData? icon; // For stat cards and standard metadata
  final double? rating;
  final bool isWishlist;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final String? imageUrl;
  final String imageType;
  final double imageAspectRatio; // For standard card (e.g. 4/3, 4/5, 16/9)
  final String? location;
  final String? category;
  final Widget? titleWidget;
  final Widget? subtitleWidget;
  final Widget? locationWidget;

  const GNCard({
    super.key,
    required this.variant,
    required this.title,
    this.subtitle,
    this.overline,
    this.value,
    this.icon,
    this.rating,
    this.isWishlist = false,
    this.onTap,
    this.onWishlistTap,
    this.imageUrl,
    this.imageType = 'network',
    this.imageAspectRatio = 4 / 3,
    this.location,
    this.category,
    this.titleWidget,
    this.subtitleWidget,
    this.locationWidget,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case GNCardVariant.standard:
        return _buildStandardCard(context);
      case GNCardVariant.hero:
        return _buildHeroCard(context);
      case GNCardVariant.compact:
        return _buildCompactCard(context);
      case GNCardVariant.stat:
        return _buildStatCard(context);
    }
  }

  // 1. Standard List Card
  Widget _buildStandardCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppSizes.borderRadiusCircular24, // radius lg (24dp)
        boxShadow: AppSizes.shadowLevel2, // upgraded to stronger shadow
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            AspectRatio(
              aspectRatio: imageAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImagePlaceholder(context),
                  // Dark Vignette scrim overlay at the bottom of the image
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                          stops: const [0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Rating Badge (Top Right)
                  if (rating != null)
                    Positioned(
                      top: AppSizes.p12,
                      right: AppSizes.p12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p8, vertical: AppSizes.p4),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(AppSizes.rPill),
                          boxShadow: AppSizes.shadowLevel1,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                            AppSizes.gapW4,
                            Text(
                              rating!.toStringAsFixed(1),
                              style: AppTypography.bodyEmphasis.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Category Badge (Top Left)
                  if (category != null || icon != null)
                    Positioned(
                      top: AppSizes.p12,
                      left: AppSizes.p12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(AppSizes.rPill),
                          boxShadow: AppSizes.shadowLevel1,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, color: AppColors.primary, size: 14),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              category ?? '',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Wishlist Toggle (Bottom Right - on image card overlay)
                  if (onWishlistTap != null)
                    Positioned(
                      bottom: AppSizes.p12,
                      right: AppSizes.p12,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.background.withValues(alpha: 0.95),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isWishlist ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            color: isWishlist ? AppColors.error : AppColors.textSecondary,
                            size: 18,
                          ),
                          onPressed: onWishlistTap,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Text Details
            Padding(
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget ?? Text(
                    title,
                    style: AppTypography.titleLarge.copyWith(fontSize: 18, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    AppSizes.gapH4,
                    subtitleWidget ?? Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (location != null && location!.isNotEmpty) ...[
                    AppSizes.gapH12,
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.textSecondary, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: locationWidget ?? Text(
                            location!,
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: location!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Address copied to clipboard'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.copy_rounded,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Hero Card (Home)
  Widget _buildHeroCard(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: AppSizes.borderRadiusCircular24, // radius lg (24dp)
        boxShadow: AppSizes.shadowLevel2,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Diagonal subtle Emerald->Teal background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.heroGradient,
                ),
              ),
            ),
            // Image Placeholder
            Opacity(
              opacity: 0.9,
              child: _buildImagePlaceholder(context),
            ),
            // Scrim bottom 40%
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Text Overlays
            Padding(
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (overline != null)
                    Text(
                      overline!.toUpperCase(),
                      style: AppTypography.overline.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  AppSizes.gapH4,
                  Text(
                    title,
                    style: AppTypography.subtitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Compact Card (fixed 160x220dp)
  Widget _buildCompactCard(BuildContext context) {
    return Container(
      width: 160,
      height: 220,
      margin: const EdgeInsets.only(right: AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppSizes.borderRadiusCircular16, // radius md (16dp)
        boxShadow: AppSizes.shadowLevel2,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top 60% Image
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImagePlaceholder(context),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                          stops: const [0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  if (onWishlistTap != null)
                    Positioned(
                      top: AppSizes.p8,
                      right: AppSizes.p8,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.background.withValues(alpha: 0.95),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isWishlist ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            color: isWishlist ? AppColors.error : AppColors.textSecondary,
                            size: 14,
                          ),
                          onPressed: onWishlistTap,
                        ),
                      ),
                    ),
                  if (rating != null)
                    Positioned(
                      bottom: AppSizes.p8,
                      left: AppSizes.p8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(AppSizes.r8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              rating!.toStringAsFixed(1),
                              style: AppTypography.bodyEmphasis.copyWith(
                                fontSize: 9, 
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom 40% Content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    titleWidget ?? Text(
                      title,
                      style: AppTypography.bodyEmphasis.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      AppSizes.gapH2,
                      subtitleWidget ?? Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Stat Card (radius md, faint surface fill, no shadow)
  Widget _buildStatCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceFaint,
        borderRadius: AppSizes.borderRadiusCircular16, // radius md (16dp)
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      padding: const EdgeInsets.all(AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value ?? '0',
                style: AppTypography.display.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  color: AppColors.secondary,
                  size: AppSizes.s24,
                ),
            ],
          ),
          AppSizes.gapH8,
          Text(
            title,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper placeholder drawer (supporting Network Images with clean load transitions)
  Widget _buildImagePlaceholder(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageType == 'file') {
        final file = File(imageUrl!);
        if (file.existsSync()) {
          return Image.file(file, fit: BoxFit.cover);
        } else {
          return Container(
            color: AppColors.surfaceFaint,
            child: const Center(
              child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 24),
            ),
          );
        }
      } else if (imageType == 'asset') {
        return Image.asset(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: AppColors.surfaceFaint,
              child: Center(
                child: Icon(
                  icon ?? Icons.landscape_rounded,
                  color: AppColors.primary.withValues(alpha: 0.2),
                  size: AppSizes.s32,
                ),
              ),
            );
          },
        );
      } else {
        return Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.surfaceFaint,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.surfaceFaint,
              child: Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error.withValues(alpha: 0.5),
                  size: AppSizes.s24,
                ),
              ),
            );
          },
        );
      }
    }

    return Container(
      color: AppColors.surfaceFaint,
      child: Center(
        child: Icon(
          icon ?? Icons.landscape_rounded,
          color: AppColors.primary.withValues(alpha: 0.2),
          size: AppSizes.s32,
        ),
      ),
    );
  }
}
