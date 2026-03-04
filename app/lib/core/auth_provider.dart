import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

/// État d'authentification et appels auth (login, register, me).
class AuthProvider extends ChangeNotifier {
  AuthProvider({this.apiBaseUrl = 'http://127.0.0.1:8000/api'}) {
    _client = ApiClient(baseUrl: apiBaseUrl);
  }

  final String apiBaseUrl;
  late final ApiClient _client;
  static const _storage = FlutterSecureStorage();

  bool _loading = true;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _authError;

  bool get loading => _loading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get authError => _authError;
  ApiClient get apiClient => _client;

  Future<void> loadToken() async {
    _loading = true;
    notifyListeners();
    try {
      final access = await _storage.read(key: 'access_token');
      final refresh = await _storage.read(key: 'refresh_token');
      if (access != null && access.isNotEmpty) {
        _client.accessToken = access;
        final res = await _client.get('/auth/me/');
        if (res.ok && res.data != null) {
          _user = res.data;
          _isAuthenticated = true;
        } else if (refresh != null && refresh.isNotEmpty) {
          final refreshRes = await _refreshToken(refresh);
          if (!refreshRes) await _logoutStorage();
        } else {
          await _logoutStorage();
        }
      }
    } catch (_) {
      await _logoutStorage();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> _refreshToken(String refresh) async {
    final res = await _client.post('/auth/token/refresh/', body: {'refresh': refresh});
    if (!res.ok || res.data == null) return false;
    final access = res.data!['access'] as String?;
    if (access == null) return false;
    await _storage.write(key: 'access_token', value: access);
    _client.accessToken = access;
    final meRes = await _client.get('/auth/me/');
    if (meRes.ok && meRes.data != null) {
      _user = meRes.data;
      _isAuthenticated = true;
      return true;
    }
    return false;
  }

  Future<void> _logoutStorage() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    _client.accessToken = null;
    _user = null;
    _isAuthenticated = false;
  }

  Future<bool> login(String username, String password) async {
    _authError = null;
    notifyListeners();
    final res = await _client.post('/auth/token/', body: {
      'username': username,
      'password': password,
    });
    if (!res.ok) {
      _authError = res.error ?? 'Identifiants incorrects.';
      notifyListeners();
      return false;
    }
    final access = res.data?['access'] as String?;
    final refresh = res.data?['refresh'] as String?;
    if (access == null || refresh == null) {
      _authError = 'Réponse serveur invalide.';
      notifyListeners();
      return false;
    }
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
    _client.accessToken = access;
    final meRes = await _client.get('/auth/me/');
    if (meRes.ok && meRes.data != null) {
      _user = meRes.data;
      _isAuthenticated = true;
    }
    notifyListeners();
    return true;
  }

  Future<bool> register(String username, String password, {String email = ''}) async {
    _authError = null;
    notifyListeners();
    final res = await _client.post('/auth/register/', body: {
      'username': username,
      'password': password,
      if (email.isNotEmpty) 'email': email,
    });
    if (!res.ok) {
      _authError = res.error ?? 'Inscription impossible.';
      notifyListeners();
      return false;
    }
    return login(username, password);
  }

  Future<void> logout() async {
    await _logoutStorage();
    notifyListeners();
  }
}
