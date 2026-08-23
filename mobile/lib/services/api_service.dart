import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'cache_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider((ref) => ApiService());

/// Thrown for any non-2xx response. [message] is the backend's actual
/// `error.message` when present, so screens can show the real reason
/// (e.g. "TRIAL_EXPIRED") instead of a generic failure text.
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

/// Wraps a [cachedGet] response — tells the caller whether data came
/// from the local SQLite cache or a fresh network call.
class CachedResponse {
  final dynamic data;
  final bool fromCache;
  const CachedResponse({required this.data, required this.fromCache});
}

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

  Future<dynamic> get(String endpoint) => _request('GET', endpoint);
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) =>
      _request('POST', endpoint, data);
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) =>
      _request('PUT', endpoint, data);
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) =>
      _request('PATCH', endpoint, data);
  Future<dynamic> delete(String endpoint, [Map<String, dynamic>? body]) => _request('DELETE', endpoint, body);

  /// Cache-first GET. Attempts a live network call and stores the result
  /// in SQLite. If the call fails (offline / server error), falls back to
  /// the last-cached value. Throws only when both network AND cache miss.
  ///
  /// [cacheKey] defaults to [endpoint] but can be overridden for endpoints
  /// with query params (e.g. `/admin/fees?status=pending` → `admin_fees_pending`).
  Future<CachedResponse> cachedGet(String endpoint, {String? cacheKey}) async {
    final key = cacheKey ?? endpoint;
    final cache = CacheService.instance;
    try {
      final fresh = await get(endpoint);
      await cache.write(key, fresh);
      return CachedResponse(data: fresh, fromCache: false);
    } catch (_) {
      final cached = await cache.read(key);
      if (cached != null) {
        return CachedResponse(data: cached, fromCache: true);
      }
      rethrow;
    }
  }

  Future<dynamic> _request(
    String method,
    String endpoint, [
    Map<String, dynamic>? data,
    bool allowRefresh = true,
  ]) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${Constants.baseUrl}$endpoint');
    final body = data != null ? json.encode(data) : null;

    http.Response response;
    switch (method) {
      case 'GET':
        response = await _client.get(uri, headers: headers);
        break;
      case 'POST':
        response = await _client.post(uri, headers: headers, body: body);
        break;
      case 'PUT':
        response = await _client.put(uri, headers: headers, body: body);
        break;
      case 'PATCH':
        response = await _client.patch(uri, headers: headers, body: body);
        break;
      case 'DELETE':
        response = await _client.delete(uri, headers: headers, body: body);
        break;
      default:
        throw ApiException('Unsupported method $method', 0);
    }

    // Access token expired (15 min TTL) — try one silent refresh, then retry
    // the original request exactly once before giving up.
    if (response.statusCode == 401 && allowRefresh) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return _request(method, endpoint, data, false);
      }
    }

    return _processResponse(response);
  }

  Future<bool> _tryRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return false;
    try {
      final response = await _client.post(
        Uri.parse('${Constants.baseUrl}/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body);
        final newAccessToken = decoded['accessToken'];
        if (newAccessToken is String) {
          await prefs.setString('auth_token', newAccessToken);
          return true;
        }
      }
    } catch (_) {
      // fall through to false
    }
    return false;
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    }

    // Backend error shape: { error: { code, message, details } }
    String message = 'Server error (${response.statusCode})';
    try {
      final errorJson = json.decode(response.body);
      if (errorJson is Map && errorJson['error'] is Map) {
        final err = errorJson['error'] as Map;
        message = (err['message'] ?? err['code'] ?? message).toString();
      } else if (errorJson is Map && errorJson['message'] != null) {
        message = errorJson['message'].toString();
      }
    } catch (_) {
      // body wasn't JSON — keep the generic message
    }
    throw ApiException(message, response.statusCode);
  }
}
