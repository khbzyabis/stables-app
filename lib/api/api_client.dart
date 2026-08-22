import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Thrown when the API returns a non-2xx status.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// A thin HTTP client for the My Stables API. Adds the base URL, the bearer
/// token, JSON headers, and a timeout, and maps errors to [ApiException].
class ApiClient {
  ApiClient({http.Client? client, String? token})
      : _client = client ?? http.Client(),
        _token = token ?? (ApiConfig.token.isEmpty ? null : ApiConfig.token);

  final http.Client _client;
  final String? _token;

  static const _timeout = Duration(seconds: 15);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null && _token.isNotEmpty)
          'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<dynamic> get(String path) async {
    final res =
        await _client.get(_uri(path), headers: _headers).timeout(_timeout);
    return _decode(res);
  }

  Future<dynamic> post(String path, Object body) async {
    final res = await _client
        .post(_uri(path), headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    String message = 'Request failed';
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (_) {/* keep default */}
    throw ApiException(res.statusCode, message);
  }

  void close() => _client.close();
}
