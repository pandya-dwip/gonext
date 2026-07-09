import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/components/gn_button.dart';
import '../providers/navigation_provider.dart';
import '../widgets/gn_curved_navigation_bar.dart';
import '../widgets/gn_add_place_sheet.dart';
import 'home_tab_view.dart';
import '../../../places/presentation/pages/restaurants_page.dart';
import '../../../places/presentation/pages/clothing_page.dart';
import '../../../places/presentation/pages/visits_page.dart';
import '../../../places/presentation/pages/wishlist_page.dart';

/// DashboardPage manages the curved notched navigation bar shell and category modal launcher.
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(dashboardTabProvider);

    return Scaffold(
      extendBody: true, // Lets screen contents scroll behind the curved bottom bar
      body: _buildBody(selectedTab),
      bottomNavigationBar: GNCurvedNavigationBar(
        selectedTab: selectedTab,
        onTabSelected: (tab) {
          ref.read(dashboardTabProvider.notifier).setTab(tab);
        },
        onHomeLongPress: _showCategorySelectionSheet,
      ),
    );
  }

  /// Launches the redesigned category selection bottom sheet modal (Phase 4.3)
  void _showCategorySelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GNAddPlaceSheet(
          onCategorySelected: (index) {
            // Proceed to the category-specific form modal (0 = Rest, 1 = Cloth, 2 = Visit)
            _showAddFormSheet(index);
          },
        );
      },
    );
  }

  /// Displays the specific input details form modal (0 = Rest, 1 = Cloth, 2 = Visit)
  void _showAddFormSheet(int categoryIndex) {
    String categoryName = 'Place';
    if (categoryIndex == 0) categoryName = 'Restaurant';
    if (categoryIndex == 1) categoryName = 'Clothing Store';
    if (categoryIndex == 2) categoryName = 'Place to Visit';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
          ),
          padding: EdgeInsets.only(
            left: AppSizes.p24,
            right: AppSizes.p24,
            top: AppSizes.p16,
            bottom: AppSizes.p24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppSizes.gapH24,
              Text(
                'Add New $categoryName',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppSizes.gapH8,
              Text(
                'Save details to your local GoNext collections.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              AppSizes.gapH24,
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Place Name',
                  hintText: 'e.g. The Bombay Canteen',
                ),
              ),
              AppSizes.gapH16,
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Address / Location',
                  hintText: 'Search or enter address',
                ),
              ),
              AppSizes.gapH24,
              Row(
                children: [
                  Expanded(
                    child: GNButton(
                      label: 'Cancel',
                      variant: GNButtonVariant.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  AppSizes.gapW16,
                  Expanded(
                    child: GNButton(
                      label: 'Save Place',
                      variant: GNButtonVariant.primary,
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Saved to your $categoryName list!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(DashboardTab tab) {
    switch (tab) {
      case DashboardTab.restaurants:
        return const RestaurantsPage();
      case DashboardTab.clothing:
        return const ClothingPage();
      case DashboardTab.home:
        return const HomeTabView();
      case DashboardTab.visits:
        return const VisitsPage();
      case DashboardTab.wishlist:
        return const WishlistPage();
    }
  }
}
