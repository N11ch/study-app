import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import 'auth_state.dart';

/// Centralised service for all authentication operations.
///
/// Always use [AuthService.instance] — never construct directly.
///
/// ```dart
/// final result = await AuthService.instance.login(
///   email: 'user@example.com',
///   password: 'secret',
/// );
/// if (result.success) {
///   Navigator.of(context).pushReplacementNamed(result.dashboardRoute);
/// } else {
///   showError(result.errorMessage!);
/// }
/// ```
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // ── Login ──────────────────────────────────────────────────────────────────

  /// POST /auth/login
  ///
  /// On success: populates [AuthState] and returns [AuthResult.success].
  /// On failure: returns [AuthResult.error] — never throws.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      _applyMockState(email: email, role: 'STUDENT');
      return AuthResult.success(role: 'STUDENT');
    }

    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(AppConfig.requestTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        AuthState.instance.setFromResponse(data);
        return AuthResult.success(role: AuthState.instance.role ?? 'STUDENT');
      }

      return AuthResult.error(
        data['message']?.toString() ?? 'Login failed (${response.statusCode})',
      );
    } on Exception catch (e) {
      return AuthResult.error(_friendlyError(e));
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────

  /// POST /auth/signup
  ///
  /// On success: populates [AuthState] and returns [AuthResult.success].
  /// On failure: returns [AuthResult.error] — never throws.
  Future<AuthResult> register({
    required String email,
    required String password,
  }) async {
    if (AppConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      _applyMockState(email: email, role: 'STUDENT');
      return AuthResult.success(role: 'STUDENT');
    }

    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiUrl}/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(AppConfig.requestTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        AuthState.instance.setFromResponse(data);
        return AuthResult.success(role: AuthState.instance.role ?? 'STUDENT');
      }

      return AuthResult.error(
        data['message']?.toString() ??
            'Registration failed (${response.statusCode})',
      );
    } on Exception catch (e) {
      return AuthResult.error(_friendlyError(e));
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  void logout() => AuthState.instance.clear();

  // ── Private helpers ────────────────────────────────────────────────────────

  void _applyMockState({required String email, required String role}) {
    AuthState.instance
      ..accessToken = 'mock-token'
      ..userId = 'mock-user-1'
      ..email = email
      ..role = role
      ..fullName = 'Muh Daffa Dwi S.';
  }

  String _friendlyError(Exception e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('TimeoutException')) {
      return 'No internet connection. Please check your network and try again.';
    }
    return 'Something went wrong. Please try again later.';
  }
}

// ── Result type ────────────────────────────────────────────────────────────────

/// Returned by every [AuthService] operation.
///
/// Check [success] before reading [role] or [errorMessage].
class AuthResult {
  final bool success;
  final String? role;
  final String? errorMessage;

  const AuthResult._({
    required this.success,
    this.role,
    this.errorMessage,
  });

  factory AuthResult.success({required String role}) =>
      AuthResult._(success: true, role: role);

  factory AuthResult.error(String message) =>
      AuthResult._(success: false, errorMessage: message);

  /// The named route for the appropriate dashboard based on [role].
  String get dashboardRoute =>
      (role?.toUpperCase() == 'TUTOR') ? '/teacher-dashboard' : '/student-dashboard';
}
