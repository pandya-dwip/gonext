import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// GNSearchableSelector displays a searchable list inside a modal bottom sheet.
class GNSearchableSelector extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? initialValue;

  const GNSearchableSelector({
    super.key,
    required this.title,
    required this.options,
    this.initialValue,
  });

  /// Helper launcher to open the selector and return the confirmed selection.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<String> options,
    String? initialValue,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GNSearchableSelector(
          title: title,
          options: options,
          initialValue: initialValue,
        );
      },
    );
  }

  @override
  State<GNSearchableSelector> createState() => _GNSearchableSelectorState();
}

class _GNSearchableSelectorState extends State<GNSearchableSelector> {
  final _searchController = TextEditingController();
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOptions = widget.options
          .where((opt) => opt.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Lock height to 75% screen
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.p24,
        AppSizes.p12,
        AppSizes.p24,
        AppSizes.p24 + keyboardHeight, // Gracefully slides up for keyboard insets
      ),
      child: Column(
        children: [
          // Drag handle and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          AppSizes.gapH12,

          // Header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: AppTypography.titleLarge.copyWith(fontSize: 22),
            ),
          ),
          AppSizes.gapH16,

          // Search Field
          TextField(
            controller: _searchController,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: 'Search options...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
            ),
          ),
          AppSizes.gapH16,

          // Options List
          Expanded(
            child: _filteredOptions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                          AppSizes.gapH16,
                          Text('No options found', style: AppTypography.bodyEmphasis),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredOptions.length,
                    separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                    itemBuilder: (context, index) {
                      final option = _filteredOptions[index];
                      final isSelected = widget.initialValue == option;

                      return ListTile(
                        title: Text(
                          option,
                          style: AppTypography.bodyEmphasis.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
                            : null,
                        contentPadding: EdgeInsets.zero,
                        onTap: () => Navigator.pop(context, option),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
