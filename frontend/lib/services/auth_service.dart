import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_config.dart';
import '../models/auth_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static const _tokenKey = 'tilapiasize-access-token-v1';
  static const _userKey = 'tilapiasize-auth-user-v1';

  Future<AuthUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return null;

    AuthUser? cachedUser;
    final rawUser = prefs.getString(_userKey);
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        cachedUser = AuthUser.fromJson(
          Map<String, dynamic>.from(jsonDecode(rawUser) as Map),
        );
      } catch (_) {
        cachedUser = null;
      }
    }

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/auth/me'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final user = AuthUser.fromJson(
          Map<String, dynamic>.from(jsonDecode(response.body) as Map),
        );
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        return user;
      }

      if (response.statusCode == 401) {
        await logout();
        return null;
      }
    } catch (_) {
      return cachedUser;
    }

    return cachedUser;
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String role,
    required String password,
  }) {
    return _authenticate(
      path: '/auth/register',
      body: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': role,
        'password': password,
      },
      successCodes: const {201},
    );
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    return _authenticate(
      path: '/auth/login',
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
      successCodes: const {200},
    );
  }

  Future<AuthUser> _authenticate({
    required String path,
    required Map<String, dynamic> body,
    required Set<int> successCodes,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(response.body) as Map);

      if (!successCodes.contains(response.statusCode)) {
        throw AuthException(_errorMessage(decoded, response.statusCode));
      }

      final token = decoded['access_token'] as String?;
      final userMap = decoded['user'];
      if (token == null || userMap is! Map) {
        throw const AuthException('The server returned an invalid response.');
      }

      final user = AuthUser.fromJson(
        Map<String, dynamic>.from(userMap),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      return user;
    } on AuthException {
      rethrow;
    } on FormatException {
      throw const AuthException('The server returned an invalid response.');
    } catch (_) {
      throw AuthException(
        'Cannot reach the TilapiaSize API at ${ApiConfig.baseUrl}. '
        'Make sure FastAPI is running.',
      );
    }
  }

  String _errorMessage(Map<String, dynamic> body, int statusCode) {
    final detail = body['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] is String) {
        return first['msg'] as String;
      }
    }
    return 'Authentication failed (HTTP $statusCode).';
  }

  Future<String?> accessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
