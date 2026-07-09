// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaceModelAdapter extends TypeAdapter<PlaceModel> {
  @override
  final typeId = 0;

  @override
  PlaceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaceModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      budget: fields[4] as String,
      location: fields[5] as String,
      rating: (fields[6] as num).toDouble(),
      isWishlist: fields[7] as bool,
      isVisited: fields[8] as bool,
      imageUrl: fields[9] as String,
      type: fields[10] as String,
      entryFee: fields[11] as String?,
      bestTime: fields[12] as String?,
      latitude: (fields[13] as num?)?.toDouble(),
      longitude: (fields[14] as num?)?.toDouble(),
      dateAdded: fields[15] as String,
      lastUpdated: fields[16] as String,
      imageType: fields[17] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlaceModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.budget)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.isWishlist)
      ..writeByte(8)
      ..write(obj.isVisited)
      ..writeByte(9)
      ..write(obj.imageUrl)
      ..writeByte(10)
      ..write(obj.type)
      ..writeByte(11)
      ..write(obj.entryFee)
      ..writeByte(12)
      ..write(obj.bestTime)
      ..writeByte(13)
      ..write(obj.latitude)
      ..writeByte(14)
      ..write(obj.longitude)
      ..writeByte(15)
      ..write(obj.dateAdded)
      ..writeByte(16)
      ..write(obj.lastUpdated)
      ..writeByte(17)
      ..write(obj.imageType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
