import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'plant.g.dart';

@JsonSerializable()
class Plant{
  Plant(this.fid,this.name,this.health,this.image,this.ml_per_watering);

  late int? fid;
  late String name;
  late String health;
  late String image;
  late int ml_per_watering;
  late int monday;
  late int tuesday;
  late int wednesday;
  late int thursday;
  late int friday;
  late int saturday;
  late int sunday;

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);

  Map<String, dynamic> toJson() => _$PlantToJson(this);

  List<bool> getWateringList(){
    var waterList = List<bool>.empty(growable: true);

    waterList.add(monday == 0 ? false : true);
    waterList.add(tuesday == 0 ? false : true);
    waterList.add(wednesday == 0 ? false : true);
    waterList.add(thursday == 0 ? false : true);
    waterList.add(friday == 0 ? false : true);
    waterList.add(saturday == 0 ? false : true);
    waterList.add(sunday == 0 ? false : true);

    return waterList;
  }

  void setWateringDays(List<int> waterList){
    monday = waterList[0];
    tuesday = waterList[1];
    wednesday = waterList[2];
    thursday = waterList[3];
    friday = waterList[4];
    saturday = waterList[5];
    sunday = waterList[6];
  }

  Uint8List getImageWidget(){
    return const Base64Decoder().convert(image);
  }

}