// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedWeatherAdapter extends TypeAdapter<CachedWeather> {
  @override
  final int typeId = 0;

  @override
  CachedWeather read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedWeather(
      city: fields[0] as String,
      jsonData: fields[1] as String,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedWeather obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.city)
      ..writeByte(1)
      ..write(obj.jsonData)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedWeatherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedAirQualityAdapter extends TypeAdapter<CachedAirQuality> {
  @override
  final int typeId = 1;

  @override
  CachedAirQuality read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedAirQuality(
      lat: fields[0] as double,
      lon: fields[1] as double,
      jsonData: fields[2] as String,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedAirQuality obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lon)
      ..writeByte(2)
      ..write(obj.jsonData)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedAirQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
