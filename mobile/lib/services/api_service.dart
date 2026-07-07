import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse('${Constants.baseUrl}$endpoint'), headers: headers);
    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await _client.post(
      Uri.parse('${Constants.baseUrl}$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
    return _processResponse(response);
  }
  
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      try {
        final errorJson = json.decode(response.body);
        throw Exception(errorJson['message'] ?? 'Request failed');
      } catch (e) {
        throw Exception('Server error: ${response.statusCode}');
      }
    }
  }
}
