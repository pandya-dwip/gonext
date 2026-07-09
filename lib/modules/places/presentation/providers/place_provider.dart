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
}

/// Provider managing the list of all stored places.
final placesListProvider = AsyncNotifierProvider<PlacesListNotifier, List<PlaceModel>>(
  PlacesListNotifier.new,
);

// Search & Sorting Notifiers with custom state setters to allow external writes cleanly
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  set state(String val) => super.state = val;
}
final placeSearchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class PlaceSortOptionNotifier extends Notifier<PlaceSortOption> {
  @override
  PlaceSortOption build() => PlaceSortOption.newest;

  set state(PlaceSortOption val) => super.state = val;
}
final placeSortOptionProvider = NotifierProvider<PlaceSortOptionNotifier, PlaceSortOption>(PlaceSortOptionNotifier.new);

// Restaurants Filter Notifiers
class RestaurantCuisineFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  set state(String val) => super.state = val;
}
final restaurantCuisineFilterProvider = NotifierProvider<RestaurantCuisineFilterNotifier, String>(RestaurantCuisineFilterNotifier.new);

class RestaurantBudgetFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  set state(String val) => super.state = val;
}
final restaurantBudgetFilterProvider = NotifierProvider<RestaurantBudgetFilterNotifier, String>(RestaurantBudgetFilterNotifier.new);

class RestaurantVisitedFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  set state(String val) => super.state = val;
}
final restaurantVisitedFilterProvider = NotifierProvider<RestaurantVisitedFilterNotifier, String>(RestaurantVisitedFilterNotifier.new);

class RestaurantRatingFilterNotifier extends Notifier<double?> {
  @override
  double? build() => null;

  set state(double? val) => super.state = val;
}
final restaurantRatingFilterProvider = NotifierProvider<RestaurantRatingFilterNotifier, double?>(RestaurantRatingFilterNotifier.new);

// Clothing Filter Notifiers
class ClothingTypeFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  set state(String val) => super.state = val;
}
final clothingTypeFilterProvider = NotifierProvider<ClothingTypeFilterNotifier, String>(ClothingTypeFilterNotifier.new);

class ClothingBudgetFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  set state(String val) => super.state = val;
}
final clothingBudgetFilterProvider = NotifierProvider<ClothingBudgetFilterNotifier, String>(ClothingBudgetFilterNotifier.new);

class ClothingVisitedFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  set state(String val) => super.state = val;
}
final clothingVisitedFilterProvider = NotifierProvider<ClothingVisitedFilterNotifier, String>(ClothingVisitedFilterNotifier.new);

// Visits Filter Notifiers
class VisitCategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  set state(String val) => super.state = val;
}
final visitCategoryFilterProvider = NotifierProvider<VisitCategoryFilterNotifier, String>(VisitCategoryFilterNotifier.new);

class VisitPriceFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  set state(String val) => super.state = val;
}
final visitPriceFilterProvider = NotifierProvider<VisitPriceFilterNotifier, String>(VisitPriceFilterNotifier.new);

class VisitVisitedFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  set state(String val) => super.state = val;
}
final visitVisitedFilterProvider = NotifierProvider<VisitVisitedFilterNotifier, String>(VisitVisitedFilterNotifier.new);

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
      final cuisine = ref.watch(restaurantCuisineFilterProvider);
      final budget = ref.watch(restaurantBudgetFilterProvider);
      final visitedStr = ref.watch(restaurantVisitedFilterProvider);
      final minRating = ref.watch(restaurantRatingFilterProvider);

      final restaurants = places.where((p) => p.type == 'restaurant').where((p) {
        if (!_matchesSearch(p, query)) return false;
        if (cuisine != 'All' && p.category != cuisine) return false;
        if (budget != 'All' && p.budget != budget) return false;
        if (visitedStr == 'Visited' && !p.isVisited) return false;
        if (visitedStr == 'Wishlist-only' && !p.isWishlist) return false;
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
      final type = ref.watch(clothingTypeFilterProvider);
      final budget = ref.watch(clothingBudgetFilterProvider);
      final visitedStr = ref.watch(clothingVisitedFilterProvider);

      final clothing = places.where((p) => p.type == 'clothing').where((p) {
        if (!_matchesSearch(p, query)) return false;
        if (type != 'All' && p.category != type) return false;
        if (budget != 'All' && p.budget != budget) return false;
        if (visitedStr == 'Visited' && !p.isVisited) return false;
        if (visitedStr == 'Wishlist-only' && !p.isWishlist) return false;
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
      final category = ref.watch(visitCategoryFilterProvider);
      final priceStr = ref.watch(visitPriceFilterProvider);
      final visitedStr = ref.watch(visitVisitedFilterProvider);

      final visits = places.where((p) => p.type == 'visit').where((p) {
        if (!_matchesSearch(p, query)) return false;
        if (category != 'All' && p.category != category) return false;
        if (priceStr == 'Free' && p.entryFee?.toLowerCase() != 'free') return false;
        if (priceStr == 'Paid' && p.entryFee?.toLowerCase() == 'free') return false;
        if (visitedStr == 'Visited' && !p.isVisited) return false;
        if (visitedStr == 'Wishlist-only' && !p.isWishlist) return false;
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
