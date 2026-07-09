import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';

/// A reusable placeholder page displaying a centered title.
/// Follows the design guidelines of plenty of white space and pure white background.
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      child: Center(
        child: Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
