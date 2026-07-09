import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the five main navigation tabs in the application.
enum DashboardTab {
  restaurants,
  clothing,
  home,
  visits,
  wishlist,
}

/// Notifier that manages the currently selected tab in the dashboard.
class DashboardTabNotifier extends Notifier<DashboardTab> {
  @override
  DashboardTab build() {
    return DashboardTab.home;
  }

  /// Updates the selected tab state
  void setTab(DashboardTab tab) {
    state = tab;
  }
}

/// Provider that manages the currently selected tab state.
final dashboardTabProvider = NotifierProvider<DashboardTabNotifier, DashboardTab>(
  DashboardTabNotifier.new,
);
