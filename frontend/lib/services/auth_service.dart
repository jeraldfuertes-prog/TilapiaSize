import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static const _accountsKey = 'tilapiasize-local-accounts-v1';
  static const _sessionKey = 'tilapiasize-session-email-v1';

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<List<Map<String, dynamic>>> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<AuthUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionEmail = prefs.getString(_sessionKey);
    if (sessionEmail == null || sessionEmail.isEmpty) return null;

    final accounts = await _loadAccounts();
    for (final account in accounts) {
      if (account['email'] == sessionEmail) {
        return AuthUser.fromJson(account);
      }
    }

    await prefs.remove(_sessionKey);
    return null;
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String role,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final normalizedEmail = _normalizeEmail(email);

    if (trimmedName.length < 2) {
      throw const AuthException('Please enter your full name.');
    }
    if (!normalizedEmail.contains('@') || !normalizedEmail.contains('.')) {
      throw const AuthException('Please enter a valid email address.');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    final accounts = await _loadAccounts();
    if (accounts.any((account) => account['email'] == normalizedEmail)) {
      throw const AuthException('An account with this email already exists.');
    }

    final user = AuthUser(
      name: trimmedName,
      email: normalizedEmail,
      role: role,
    );

    // Prototype only: replace this local credential store with FastAPI/JWT auth.
    accounts.add({
      ...user.toJson(),
      'password': password,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(accounts));
    await prefs.setString(_sessionKey, normalizedEmail);
    return user;
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final accounts = await _loadAccounts();

    for (final account in accounts) {
      if (account['email'] == normalizedEmail &&
          account['password'] == password) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, normalizedEmail);
        return AuthUser.fromJson(account);
      }
    }

    throw const AuthException('Incorrect email or password.');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
