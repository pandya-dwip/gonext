import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/navigation_provider.dart';
import '../widgets/gn_curved_navigation_bar.dart';
import '../widgets/gn_add_place_sheet.dart';
import 'home_tab_view.dart';
import '../../../places/presentation/pages/restaurants_page.dart';
import '../../../places/presentation/pages/clothing_page.dart';
import '../../../places/presentation/pages/visits_page.dart';
import '../../../places/presentation/pages/wishlist_page.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

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
    // Listen to settings updates for immediate visual refresh of shell elements
    ref.watch(accentColorProvider);
    ref.watch(themeModeProvider);

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
            if (index == 0) {
              context.push('/add-restaurant');
            } else if (index == 1) {
              context.push('/add-clothing');
            } else if (index == 2) {
              context.push('/add-visit');
            }
          },
        );
      },
    );
  }

  Widget _buildBody(DashboardTab tab) {
    switch (tab) {
      case DashboardTab.restaurants:
        return RestaurantsPage();
      case DashboardTab.clothing:
        return ClothingPage();
      case DashboardTab.home:
        return HomeTabView();
      case DashboardTab.visits:
        return VisitsPage();
      case DashboardTab.wishlist:
        return WishlistPage();
    }
  }
}
