import 'package:hive_ce/hive.dart';
import '../../domain/entities/place.dart';

part 'place_model.g.dart';

@HiveType(typeId: 0)
class PlaceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String budget;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final double rating;

  @HiveField(7)
  final bool isWishlist;

  @HiveField(8)
  final bool isVisited;

  @HiveField(9)
  final String imageUrl;

  @HiveField(10)
  final String type;

  @HiveField(11)
  final String? entryFee;

  @HiveField(12)
  final String? bestTime;

  @HiveField(13)
  final double? latitude;

  @HiveField(14)
  final double? longitude;

  @HiveField(15)
  final String dateAdded;

  @HiveField(16)
  final String lastUpdated;

  @HiveField(17)
  final String imageType; // 'asset', 'file', 'network'

  PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.budget,
    required this.location,
    required this.rating,
    required this.isWishlist,
    required this.isVisited,
    required this.imageUrl,
    required this.type,
    this.entryFee,
    this.bestTime,
    this.latitude,
    this.longitude,
    required this.dateAdded,
    required this.lastUpdated,
    required this.imageType,
  });

  Place toEntity() {
    return Place(
      id: id,
      name: name,
      description: description,
      category: category,
      budget: budget,
      location: location,
      rating: rating,
      isWishlist: isWishlist,
      isVisited: isVisited,
      imageUrl: imageUrl,
      type: type,
      latitude: latitude,
      longitude: longitude,
      entryFee: entryFee,
      bestTime: bestTime,
      dateAdded: dateAdded,
      lastUpdated: lastUpdated,
    );
  }

  factory PlaceModel.fromEntity(Place entity, {required String imageType, double? latitude, double? longitude}) {
    return PlaceModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      budget: entity.budget,
      location: entity.location,
      rating: entity.rating,
      isWishlist: entity.isWishlist,
      isVisited: entity.isVisited,
      imageUrl: entity.imageUrl,
      type: entity.type,
      entryFee: entity.entryFee,
      bestTime: entity.bestTime,
      latitude: latitude ?? entity.latitude,
      longitude: longitude ?? entity.longitude,
      dateAdded: entity.dateAdded,
      lastUpdated: entity.lastUpdated,
      imageType: imageType,
    );
  }
}
