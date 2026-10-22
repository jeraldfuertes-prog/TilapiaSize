import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'models/auth_user.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'services/auth_service.dart';

class TilapiaSizeApp extends StatefulWidget {
  const TilapiaSizeApp({super.key});

  @override
  State<TilapiaSizeApp> createState() => _TilapiaSizeAppState();
}

class _TilapiaSizeAppState extends State<TilapiaSizeApp> {
  final _authService = AuthService();
  AuthUser? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = await _authService.currentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TilapiaSize — Automated Fish Size Grading',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _loading
          ? const _StartupScreen()
          : _user == null
              ? AuthScreen(
                  onAuthenticated: (user) => setState(() => _user = user),
                )
              : HomeShell(
                  user: _user!,
                  onLogout: _logout,
                ),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
