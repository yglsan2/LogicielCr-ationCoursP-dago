import 'dart:convert';
import 'package:http/http.dart' as http;

/// Client API pour le backend Django. Base URL configurable.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    this.accessToken,
  });

  final String baseUrl;
  String? accessToken;

  String get _authHeader => 'Bearer $accessToken';

  Future<ApiResponse> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': _authHeader,
      },
    );
    return _handleResponse(response);
  }

  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': _authHeader,
      },
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<ApiResponse> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': _authHeader,
      },
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': _authHeader,
      },
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<ApiResponse> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': _authHeader,
      },
    );
    return _handleResponse(response);
  }

  ApiResponse _handleResponse(http.Response response) {
    final status = response.statusCode;
    dynamic data;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        data = decoded is Map ? decoded : {'results': decoded};
      } catch (_) {
        data = {'detail': response.body};
      }
    }
    if (status >= 200 && status < 300) {
      return ApiResponse(ok: true, statusCode: status, data: data);
    }
    final msg = data is Map ? (data['detail'] ?? data['message'] ?? 'Erreur inconnue') : 'Erreur inconnue';
    return ApiResponse(
      ok: false,
      statusCode: status,
      data: data is Map ? data : null,
      error: msg is String ? msg : msg.toString(),
    );
  }
}

class ApiResponse {
  ApiResponse({
    required this.ok,
    required this.statusCode,
    this.data,
    this.error,
  });

  final bool ok;
  final int statusCode;
  final dynamic data;
  final String? error;
}
