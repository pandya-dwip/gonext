/// Place represents the core domain model entity for GoNext.
/// It contains attributes used by all three place categories.
class Place {
  final String id;
  final String name;
  final String description;
  final String category; // cuisine, clothing store type, visit category
  final String budget;   // pricing scale (e.g. ₹, ₹₹, ₹₹₹)
  final String location;
  final double rating;
  final bool isWishlist;
  final bool isVisited;
  final String imageUrl;
  final String type;     // 'restaurant', 'clothing', 'visit'
  final double? latitude;
  final double? longitude;

  // Landmark/Sightseeing details
  final String? entryFee;
  final String? bestTime; // best season

  // Metadata timestamps
  final String dateAdded;
  final String lastUpdated;

  const Place({
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
    this.latitude,
    this.longitude,
    this.entryFee,
    this.bestTime,
    required this.dateAdded,
    required this.lastUpdated,
  });
}
