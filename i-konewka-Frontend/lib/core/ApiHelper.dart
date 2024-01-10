import 'dart:convert';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:i_konewka_app/main.dart';

class ApiHelper {
  final String baseUrl;

  ApiHelper(this.baseUrl);

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postAuth(String endpoint, Map<String, dynamic> data) async {
    String? token = await storage.read(key: 'jwt');
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postAuthParams(String endpoint, Map<String, dynamic> data, Map<String, dynamic> parameters) async {
    String? token = await storage.read(key: 'jwt');
    print("jd");
    print("Token" + token!);
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint').replace(queryParameters:
      parameters.map((key, value)
      => MapEntry(key, value.toString())
      )
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    String? token = await storage.read(key: 'jwt');
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    String? token = await storage.read(key: 'jwt');
    print('Bearer $token');
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getParams(String endpoint,Map<String, dynamic> parameters) async {
    String? token = await storage.read(key: 'jwt');
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}\n${data['error']}');
      }
    } catch (e) {
      // If parsing as JSON fails, assume it's a plain string
      return {'message': response.body};
    }
  }
}