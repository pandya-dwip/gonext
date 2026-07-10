import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/place_repository_impl.dart';
import '../../domain/repositories/place_repository.dart';

enum PlaceSortOption {
  newest,
  oldest,
  highestRated,
  alphabetical,
  recentlyUpdated,
}

/// Provider for the PlaceRepository instance.
final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepositoryImpl();
});

/// Notifier that manages the raw list of saved places inside the Hive repository.
class PlacesListNotifier extends AsyncNotifier<List<PlaceModel>> {
  late final PlaceRepository _repo;

  @override
  Future<List<PlaceModel>> build() async {
    _repo = ref.watch(placeRepositoryProvider);
    return await _repo.getAllPlaces();
  }

  Future<void> addPlace(PlaceModel place) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.savePlace(place);
      return await _repo.getAllPlaces();
    });
  }

  Future<void> updatePlace(PlaceModel place) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.savePlace(place);
      return await _repo.getAllPlaces();
    });
  }

  Future<void> deletePlace(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deletePlace(id);
      return await _repo.getAllPlaces();
    });
  }

  Future<void> loadDemoData(List<PlaceModel> demoPlaces) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.savePlaces(demoPlaces);
      return await _repo.getAllPlaces();
    });
  }

  Future<void> clearDemoData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = await _repo.getAllPlaces();
      for (final p in current) {
        if (p.isDemoData) {
          await _repo.deletePlace(p.id);
        }
      }
      return await _repo.getAllPlaces();
    });
  }

  Future<void> restoreData(List<PlaceModel> places) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.clearAll();
      await _repo.savePlaces(places);
      return await _repo.getAllPlaces();
    });
  }
}

/// Provider managing the list of all stored places.
final placesListProvider = AsyncNotifierProvider<PlacesListNotifier, List<PlaceModel>>(
  PlacesListNotifier.new,
);

// Search & Sorting Notifiers with custom state setters to allow external writes cleanly
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  @override
  set state(String val) => super.state = val;
}
final placeSearchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class PlaceSortOptionNotifier extends Notifier<PlaceSortOption> {
  @override
  PlaceSortOption build() => PlaceSortOption.newest;

  @override
  set state(PlaceSortOption val) => super.state = val;
}
final placeSortOptionProvider = NotifierProvider<PlaceSortOptionNotifier, PlaceSortOption>(PlaceSortOptionNotifier.new);

// SetFilterNotifier provides a generic set-based filter state notifier
class SetFilterNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String val) {
    if (state.contains(val)) {
      state = state.difference({val});
    } else {
      state = state.union({val});
    }
  }

  void clear() {
    state = {};
  }
}

// Restaurants Filter Notifiers
class RestaurantCuisineFilterNotifier extends SetFilterNotifier {}
final restaurantCuisineFilterProvider = NotifierProvider<RestaurantCuisineFilterNotifier, Set<String>>(RestaurantCuisineFilterNotifier.new);

class RestaurantBudgetFilterNotifier extends SetFilterNotifier {}
final restaurantBudgetFilterProvider = NotifierProvider<RestaurantBudgetFilterNotifier, Set<String>>(RestaurantBudgetFilterNotifier.new);

class RestaurantVisitedFilterNotifier extends SetFilterNotifier {}
final restaurantVisitedFilterProvider = NotifierProvider<RestaurantVisitedFilterNotifier, Set<String>>(RestaurantVisitedFilterNotifier.new);

class RestaurantWishlistFilterNotifier extends SetFilterNotifier {}
final restaurantWishlistFilterProvider = NotifierProvider<RestaurantWishlistFilterNotifier, Set<String>>(RestaurantWishlistFilterNotifier.new);

class RestaurantRatingFilterNotifier extends Notifier<double?> {
  @override
  double? build() => null;

  @override
  set state(double? val) => super.state = val;
}
final restaurantRatingFilterProvider = NotifierProvider<RestaurantRatingFilterNotifier, double?>(RestaurantRatingFilterNotifier.new);

// Clothing Filter Notifiers
class ClothingTypeFilterNotifier extends SetFilterNotifier {}
final clothingTypeFilterProvider = NotifierProvider<ClothingTypeFilterNotifier, Set<String>>(ClothingTypeFilterNotifier.new);

class ClothingBudgetFilterNotifier extends SetFilterNotifier {}
final clothingBudgetFilterProvider = NotifierProvider<ClothingBudgetFilterNotifier, Set<String>>(ClothingBudgetFilterNotifier.new);

class ClothingVisitedFilterNotifier extends SetFilterNotifier {}
final clothingVisitedFilterProvider = NotifierProvider<ClothingVisitedFilterNotifier, Set<String>>(ClothingVisitedFilterNotifier.new);

class ClothingWishlistFilterNotifier extends SetFilterNotifier {}
final clothingWishlistFilterProvider = NotifierProvider<ClothingWishlistFilterNotifier, Set<String>>(ClothingWishlistFilterNotifier.new);

// Visits Filter Notifiers
class VisitCategoryFilterNotifier extends SetFilterNotifier {}
final visitCategoryFilterProvider = NotifierProvider<VisitCategoryFilterNotifier, Set<String>>(VisitCategoryFilterNotifier.new);

class VisitBudgetFilterNotifier extends SetFilterNotifier {}
final visitBudgetFilterProvider = NotifierProvider<VisitBudgetFilterNotifier, Set<String>>(VisitBudgetFilterNotifier.new);

class VisitVisitedFilterNotifier extends SetFilterNotifier {}
final visitVisitedFilterProvider = NotifierProvider<VisitVisitedFilterNotifier, Set<String>>(VisitVisitedFilterNotifier.new);

class VisitWishlistFilterNotifier extends SetFilterNotifier {}
final visitWishlistFilterProvider = NotifierProvider<VisitWishlistFilterNotifier, Set<String>>(VisitWishlistFilterNotifier.new);

// Home Search Provider
class HomeSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  @override
  set state(String val) => super.state = val;
}
final homeSearchQueryProvider = NotifierProvider<HomeSearchQueryNotifier, String>(HomeSearchQueryNotifier.new);

// Grouped Search Results for Dashboard
class GroupedSearchResults {
  final List<PlaceModel> restaurants;
  final List<PlaceModel> clothing;
  final List<PlaceModel> visits;

  GroupedSearchResults({
    required this.restaurants,
    required this.clothing,
    required this.visits,
  });

  bool get isEmpty => restaurants.isEmpty && clothing.isEmpty && visits.isEmpty;
}

final groupedSearchResultsProvider = Provider<GroupedSearchResults>((ref) {
  final query = ref.watch(homeSearchQueryProvider);
  if (query.isEmpty) {
    return GroupedSearchResults(restaurants: [], clothing: [], visits: []);
  }

  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) {
      final restaurants = places
          .where((p) => p.type == 'restaurant' && _matchesSearch(p, query))
          .toList();
      final clothing = places
          .where((p) => p.type == 'clothing' && _matchesSearch(p, query))
          .toList();
      final visits = places
          .where((p) => p.type == 'visit' && _matchesSearch(p, query))
          .toList();
      return GroupedSearchResults(
        restaurants: restaurants,
        clothing: clothing,
        visits: visits,
      );
    },
    orElse: () => GroupedSearchResults(restaurants: [], clothing: [], visits: []),
  );
});

// Dynamic available option providers generated from stored data
final availableRestaurantCuisinesProvider = Provider<List<String>>((ref) {
  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) => places
        .where((p) => p.type == 'restaurant')
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort(),
    orElse: () => [],
  );
});

final availableRestaurantBudgetsProvider = Provider<List<String>>((ref) {
  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) => places
        .where((p) => p.type == 'restaurant')
        .map((p) => p.budget)
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList()
      ..sort(),
    orElse: () => [],
  );
});

final availableClothingTypesProvider = Provider<List<String>>((ref) {
  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) => places
        .where((p) => p.type == 'clothing')
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort(),
    orElse: () => [],
  );
});

final availableClothingBudgetsProvider = Provider<List<String>>((ref) {
  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) => places
        .where((p) => p.type == 'clothing')
        .map((p) => p.budget)
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList()
      ..sort(),
    orElse: () => [],
  );
});

final availableVisitCategoriesProvider = Provider<List<String>>((ref) {
  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) => places
        .where((p) => p.type == 'visit')
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort(),
    orElse: () => [],
  );
});

final availableVisitBudgetsProvider = Provider<List<String>>((ref) {
  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) => places
        .where((p) => p.type == 'visit')
        .map((p) => p.budget)
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList()
      ..sort(),
    orElse: () => [],
  );
});

// Helpers for Sorting and Filtering
List<PlaceModel> _sortPlaces(List<PlaceModel> list, PlaceSortOption option) {
  final sorted = List<PlaceModel>.from(list);
  switch (option) {
    case PlaceSortOption.newest:
      sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      break;
    case PlaceSortOption.oldest:
      sorted.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
      break;
    case PlaceSortOption.highestRated:
      sorted.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case PlaceSortOption.alphabetical:
      sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case PlaceSortOption.recentlyUpdated:
      sorted.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      break;
  }
  return sorted;
}

bool _matchesSearch(PlaceModel place, String query) {
  if (query.isEmpty) return true;
  final q = query.toLowerCase();
  return place.name.toLowerCase().contains(q) ||
      place.description.toLowerCase().contains(q) ||
      place.category.toLowerCase().contains(q) ||
      place.location.toLowerCase().contains(q);
}

// Computed Filtered List Providers
final filteredRestaurantsProvider = Provider<List<PlaceModel>>((ref) {
  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) {
      final query = ref.watch(placeSearchQueryProvider);
      final sort = ref.watch(placeSortOptionProvider);
      final selectedCuisines = ref.watch(restaurantCuisineFilterProvider);
      final selectedBudgets = ref.watch(restaurantBudgetFilterProvider);
      final selectedVisited = ref.watch(restaurantVisitedFilterProvider);
      final selectedWishlist = ref.watch(restaurantWishlistFilterProvider);
      final minRating = ref.watch(restaurantRatingFilterProvider);

      final restaurants = places.where((p) => p.type == 'restaurant').where((p) {
        if (!_matchesSearch(p, query)) return false;
        
        if (selectedCuisines.isNotEmpty && !selectedCuisines.contains(p.category)) return false;
        if (selectedBudgets.isNotEmpty && !selectedBudgets.contains(p.budget)) return false;
        
        if (selectedVisited.isNotEmpty) {
          if (selectedVisited.contains('Visited') && !selectedVisited.contains('Not Visited') && !p.isVisited) return false;
          if (selectedVisited.contains('Not Visited') && !selectedVisited.contains('Visited') && p.isVisited) return false;
        }
        
        if (selectedWishlist.isNotEmpty) {
          if (selectedWishlist.contains('Wishlist') && !selectedWishlist.contains('Not Wishlist') && !p.isWishlist) return false;
          if (selectedWishlist.contains('Not Wishlist') && !selectedWishlist.contains('Wishlist') && p.isWishlist) return false;
        }

        if (minRating != null && p.rating < minRating) return false;
        return true;
      }).toList();

      return _sortPlaces(restaurants, sort);
    },
    orElse: () => [],
  );
});

final filteredClothingProvider = Provider<List<PlaceModel>>((ref) {
  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) {
      final query = ref.watch(placeSearchQueryProvider);
      final sort = ref.watch(placeSortOptionProvider);
      final selectedTypes = ref.watch(clothingTypeFilterProvider);
      final selectedBudgets = ref.watch(clothingBudgetFilterProvider);
      final selectedVisited = ref.watch(clothingVisitedFilterProvider);
      final selectedWishlist = ref.watch(clothingWishlistFilterProvider);

      final clothing = places.where((p) => p.type == 'clothing').where((p) {
        if (!_matchesSearch(p, query)) return false;
        
        if (selectedTypes.isNotEmpty && !selectedTypes.contains(p.category)) return false;
        if (selectedBudgets.isNotEmpty && !selectedBudgets.contains(p.budget)) return false;
        
        if (selectedVisited.isNotEmpty) {
          if (selectedVisited.contains('Visited') && !selectedVisited.contains('Not Visited') && !p.isVisited) return false;
          if (selectedVisited.contains('Not Visited') && !selectedVisited.contains('Visited') && p.isVisited) return false;
        }
        
        if (selectedWishlist.isNotEmpty) {
          if (selectedWishlist.contains('Wishlist') && !selectedWishlist.contains('Not Wishlist') && !p.isWishlist) return false;
          if (selectedWishlist.contains('Not Wishlist') && !selectedWishlist.contains('Wishlist') && p.isWishlist) return false;
        }

        return true;
      }).toList();

      return _sortPlaces(clothing, sort);
    },
    orElse: () => [],
  );
});

final filteredVisitsProvider = Provider<List<PlaceModel>>((ref) {
  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) {
      final query = ref.watch(placeSearchQueryProvider);
      final sort = ref.watch(placeSortOptionProvider);
      final selectedCategories = ref.watch(visitCategoryFilterProvider);
      final selectedBudgets = ref.watch(visitBudgetFilterProvider);
      final selectedVisited = ref.watch(visitVisitedFilterProvider);
      final selectedWishlist = ref.watch(visitWishlistFilterProvider);

      final visits = places.where((p) => p.type == 'visit').where((p) {
        if (!_matchesSearch(p, query)) return false;
        
        if (selectedCategories.isNotEmpty && !selectedCategories.contains(p.category)) return false;
        if (selectedBudgets.isNotEmpty && !selectedBudgets.contains(p.budget)) return false;
        
        if (selectedVisited.isNotEmpty) {
          if (selectedVisited.contains('Visited') && !selectedVisited.contains('Not Visited') && !p.isVisited) return false;
          if (selectedVisited.contains('Not Visited') && !selectedVisited.contains('Visited') && p.isVisited) return false;
        }
        
        if (selectedWishlist.isNotEmpty) {
          if (selectedWishlist.contains('Wishlist') && !selectedWishlist.contains('Not Wishlist') && !p.isWishlist) return false;
          if (selectedWishlist.contains('Not Wishlist') && !selectedWishlist.contains('Wishlist') && p.isWishlist) return false;
        }

        return true;
      }).toList();

      return _sortPlaces(visits, sort);
    },
    orElse: () => [],
  );
});

final filteredWishlistProvider = Provider<List<PlaceModel>>((ref) {
  final placesAsync = ref.watch(placesListProvider);
  return placesAsync.maybeWhen(
    data: (places) {
      final query = ref.watch(placeSearchQueryProvider);
      final wishlist = places.where((p) => p.isWishlist).where((p) {
        return _matchesSearch(p, query);
      }).toList();

      // Wishlist sorted by newest first
      wishlist.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      return wishlist;
    },
    orElse: () => [],
  );
});
