import 'package:hive_ce/hive.dart';
import '../../domain/repositories/place_repository.dart';
import '../models/place_model.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  static const String _boxName = 'places_box';

  Future<Box<PlaceModel>> get _box async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<PlaceModel>(_boxName);
    }
    return await Hive.openBox<PlaceModel>(_boxName);
  }

  @override
  Future<List<PlaceModel>> getAllPlaces() async {
    final box = await _box;
    return box.values.toList();
  }

  @override
  Future<void> savePlace(PlaceModel place) async {
    final box = await _box;
    await box.put(place.id, place);
  }

  @override
  Future<void> deletePlace(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
