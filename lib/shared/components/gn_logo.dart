import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// GNLogo is the redesigned modern abstract application logo (Map Marker + Star).
/// Circular shape, clean brand gradient, and highly visible in light and dark mode.
class GNLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const GNLogo({
    super.key,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.primary;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer subtle compass ring
            Container(
              width: size * 0.78,
              height: size * 0.78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: size * 0.03,
                ),
              ),
            ),
            // Map Marker
            Icon(
              Icons.location_on_rounded,
              size: size * 0.45,
              color: Colors.white,
            ),
            // Inner Recommend Star
            Positioned(
              top: size * 0.275,
              child: Icon(
                Icons.star_rounded,
                size: size * 0.16,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
