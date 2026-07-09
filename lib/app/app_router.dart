import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../modules/dashboard/presentation/pages/dashboard_page.dart';
import '../modules/splash/presentation/pages/splash_page.dart';
import '../modules/settings/presentation/pages/settings_page.dart';
import '../modules/places/presentation/pages/add_restaurant_page.dart';
import '../modules/places/presentation/pages/add_clothing_page.dart';
import '../modules/places/presentation/pages/add_visit_page.dart';
import '../modules/places/presentation/pages/restaurant_detail_page.dart';
import '../modules/places/presentation/pages/clothing_detail_page.dart';
import '../modules/places/presentation/pages/place_detail_page.dart';
import '../modules/places/presentation/pages/location_picker_page.dart';
/// Provider for the application's central [GoRouter] instance.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/add-restaurant',
        name: 'add-restaurant',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return AddRestaurantPage(editPlaceId: id);
        },
      ),
      GoRoute(
        path: '/add-clothing',
        name: 'add-clothing',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return AddClothingPage(editPlaceId: id);
        },
      ),
      GoRoute(
        path: '/add-visit',
        name: 'add-visit',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return AddVisitPage(editPlaceId: id);
        },
      ),
      GoRoute(
        path: '/restaurant-detail/:id',
        name: 'restaurant-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'rest-1';
          return RestaurantDetailPage(id: id);
        },
      ),
      GoRoute(
        path: '/clothing-detail/:id',
        name: 'clothing-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'cloth-1';
          return ClothingDetailPage(id: id);
        },
      ),
      GoRoute(
        path: '/place-detail/:id',
        name: 'place-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'visit-1';
          return PlaceDetailPage(id: id);
        },
      ),
      GoRoute(
        path: '/location-picker',
        name: 'location-picker',
        builder: (context, state) {
          final latVal = state.uri.queryParameters['lat'];
          final lngVal = state.uri.queryParameters['lng'];
          final lat = latVal != null ? double.tryParse(latVal) : null;
          final lng = lngVal != null ? double.tryParse(lngVal) : null;
          return LocationPickerPage(initialLatitude: lat, initialLongitude: lng);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Error: ${state.error}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ),
  );
});
