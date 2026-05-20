// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedLocationAdapter extends TypeAdapter<SavedLocation> {
  @override
  final int typeId = 0;

  @override
  SavedLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedLocation(
      id: fields[0] as String?,
      name: fields[1] as String,
      displayName: fields[2] as String?,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SavedLocation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertLocationAdapter extends TypeAdapter<AlertLocation> {
  @override
  final int typeId = 1;

  @override
  AlertLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertLocation(
      id: fields[0] as String,
      name: fields[1] as String,
      latitude: fields[2] as double?,
      longitude: fields[3] as double?,
      displayName: fields[4] as String?,
      enabled: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AlertLocation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.displayName)
      ..writeByte(5)
      ..write(obj.enabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationVisitAdapter extends TypeAdapter<LocationVisit> {
  @override
  final int typeId = 2;

  @override
  LocationVisit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationVisit(
      locationName: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      visitedAt: fields[3] as DateTime,
      searchCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LocationVisit obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.locationName)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.visitedAt)
      ..writeByte(4)
      ..write(obj.searchCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationVisitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
