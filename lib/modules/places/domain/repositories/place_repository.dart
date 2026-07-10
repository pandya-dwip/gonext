import '../../data/models/place_model.dart';

abstract class PlaceRepository {
  Future<List<PlaceModel>> getAllPlaces();
  Future<void> savePlace(PlaceModel place);
  Future<void> deletePlace(String id);
  Future<void> clearAll();
  Future<void> savePlaces(List<PlaceModel> places);
}
