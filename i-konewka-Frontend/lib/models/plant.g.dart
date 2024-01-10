// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plant _$PlantFromJson(Map<String, dynamic> json) => Plant(
      json['fid'] as int?,
      json['name'] as String,
      json['health'] as String,
      json['image'] as String,
      json['ml_per_watering'] as int,
    )
      ..monday = json['monday'] as int
      ..tuesday = json['tuesday'] as int
      ..wednesday = json['wednesday'] as int
      ..thursday = json['thursday'] as int
      ..friday = json['friday'] as int
      ..saturday = json['saturday'] as int
      ..sunday = json['sunday'] as int;

Map<String, dynamic> _$PlantToJson(Plant instance) => <String, dynamic>{
      'fid': instance.fid,
      'name': instance.name,
      'health': instance.health,
      'image': instance.image,
      'ml_per_watering': instance.ml_per_watering,
      'monday': instance.monday,
      'tuesday': instance.tuesday,
      'wednesday': instance.wednesday,
      'thursday': instance.thursday,
      'friday': instance.friday,
      'saturday': instance.saturday,
      'sunday': instance.sunday,
    };
