import 'dart:convert';

import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:i_konewka_app/main.dart';
import 'package:i_konewka_app/models/plant.dart';

import 'ApiHelper.dart';

class RequestHandler {
  final api = ApiHelper('https://ikonewka.panyre.pl');

  Future<bool> login(String email, String password) async {
    try {
      var postData = {'email': email, 'password': password};
      var responsePost = await api.post('/auth/login', postData);
      print('Response' + responsePost.toString());
      String token = responsePost['message'];
      token = token.replaceAllMapped(RegExp(r'^\s+|\s+$'), (match) => "");
      token = token.replaceAll("\"", "");
      print("Token:" + token);
      await storage.write(key: 'jwt', value: token);
      if (token != "{error:Invalid email or password}") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(
      String email, String password, String nick, String wateringHour) async {
    try {
      var postData = {
        'email': email,
        'password': password,
        'nick': nick,
        'watering_hour': wateringHour
      };
      var responsePost = await api.post('/auth/register', postData);
      print('Register Response: $responsePost');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Plant>?> getPlants() async {
    try {
      var response = await api.get('/api/user_flowers');
      print('Register Response: $response');
      var parsedPlants = response["user_flowers"] as List;
      List<Plant> plantList =
          parsedPlants.map((tagJson) => Plant.fromJson(tagJson)).toList();
      return plantList;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<int> addPlant(String name, String? encodedImage) async {
    try {
      var postData = {'flower_name': name, 'flower_image': encodedImage};
      var response = await api.postAuth('/api/flower', postData);
      var flower = response['message']['flower_id'];
      print('flower_id: ' + flower.toString());
      return flower;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<bool> editPlant(
      String name, int mlWatering, List<bool> wateringList, int fid) async {
    try {
      var postData = {
        'name': name,
        'ml_per_watering': 20,
        'monday': wateringList[0] ? 1 : 0,
        'tuesday': wateringList[1] ? 1 : 0,
        'wednesday': wateringList[2] ? 1 : 0,
        'thursday': wateringList[3] ? 1 : 0,
        'friday': wateringList[4] ? 1 : 0,
        'saturday': wateringList[5] ? 1 : 0,
        'sunday': wateringList[6] ? 1 : 0,
      };
      print('data' + postData.toString());
      var response = await api.put('/api/flower/$fid', postData);
      print('Register Response: $response');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Plant?> getPlant(int fid) async {
    try {
      var response = await api.get('/api/flower/$fid');
      print('Register New Response: $response');
      var parsedPlant = response["flower_detail"];
      Plant plant = Plant.fromJson(parsedPlant);
      return plant;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> addPhoto(int fid, String? encodedImage) async {
    try {
      var postData = {'fid': fid, 'image': encodedImage};
      var response = await api.postAuth('/api/flower_photo', postData);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
