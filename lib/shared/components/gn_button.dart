import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_typography.dart';

enum GNButtonVariant {
  primary,
  secondary,
  text,
  destructive,
}

/// GNButton is a premium button component conforming to the design document specs.
class GNButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final GNButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  const GNButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = GNButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    // Define geometric constraints (height)
    final double buttonHeight = variant == GNButtonVariant.text ? 44.0 : 52.0;

    Widget buttonChild;
    if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppSizes.s20),
          AppSizes.gapW8,
          Text(label),
        ],
      );
    } else {
      buttonChild = Text(label);
    }

    Widget result;
    switch (variant) {
      case GNButtonVariant.primary:
        result = FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 88, buttonHeight),
            maximumSize: Size(double.infinity, buttonHeight),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
            disabledForegroundColor: AppColors.background.withValues(alpha: 0.6),
            elevation: 0,
            shape: const StadiumBorder(),
          ),
          child: buttonChild,
        );
        break;

      case GNButtonVariant.secondary:
        result = OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 88, buttonHeight),
            maximumSize: Size(double.infinity, buttonHeight),
            side: BorderSide(color: AppColors.primary, width: 1.5),
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.primary.withValues(alpha: 0.4),
            elevation: 0,
            shape: const StadiumBorder(),
          ),
          child: buttonChild,
        );
        break;

      case GNButtonVariant.destructive:
        result = FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 88, buttonHeight),
            maximumSize: Size(double.infinity, buttonHeight),
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.background,
            disabledBackgroundColor: AppColors.error.withValues(alpha: 0.4),
            disabledForegroundColor: AppColors.background.withValues(alpha: 0.6),
            elevation: 0,
            shape: const StadiumBorder(),
          ),
          child: buttonChild,
        );
        break;

      case GNButtonVariant.text:
        result = TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 44, buttonHeight),
            maximumSize: Size(double.infinity, buttonHeight),
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textSecondary.withValues(alpha: 0.4),
            textStyle: AppTypography.bodyEmphasis,
            shape: const StadiumBorder(),
          ),
          child: buttonChild,
        );
        break;
    }

    return SizedBox(
      height: buttonHeight < 44.0 ? 44.0 : buttonHeight,
      child: result,
    );
  }
}
