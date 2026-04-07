import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import 'auth_state.dart';

/// Global service for all user-related API calls.
/// Use [UserApiService.instance] to access it anywhere in the app.
///
/// Example:
/// ```dart
/// final result = await UserApiService.instance.updateProfile(
///   username: 'john_doe',
///   fullName: 'John Doe',
///   role: 'STUDENT',
/// );
/// ```
class UserApiService {
  UserApiService._();
  static final UserApiService instance = UserApiService._();

  // ─── Update Profile ───────────────────────────────────────────────────────

  /// PATCH /user/update/profile
  ///
  /// Updates the authenticated user's profile. All fields are optional —
  /// only include the ones you want to change.
  ///
  /// Requires the user to be logged in ([AuthState.instance.isLoggedIn] == true).
  ///
  /// Returns an [UpdateProfileResult] with either the updated user data or an
  /// error message. Never throws — errors are returned in the result object.
  ///
  /// Example:
  /// ```dart
  /// final result = await UserApiService.instance.updateProfile(
  ///   username: 'john_doe',
  ///   fullName: 'John Doe',
  ///   bio: 'I love math',
  ///   role: 'STUDENT',
  /// );
  ///
  /// if (result.success) {
  ///   print('Updated: ${result.user}');
  /// } else {
  ///   print('Error: ${result.errorMessage}');
  /// }
  /// ```
  Future<UpdateProfileResult> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? role,
  }) async {
    if (!AuthState.instance.isLoggedIn) {
      return UpdateProfileResult.error('Not authenticated. Please log in first.');
    }

    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (fullName != null) body['full_name'] = fullName;
    if (bio != null) body['bio'] = bio;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    if (role != null) body['role'] = role;

    try {
      final response = await http.patch(
        Uri.parse('${AppConfig.apiUrl}/user/update/profile'),
        headers: AuthState.instance.authHeaders,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UpdateProfileResult.success(data['user'] as Map<String, dynamic>);
      }

      final message = data['message']?.toString() ?? 'Update failed (${response.statusCode})';
      return UpdateProfileResult.error(message);
    } catch (e) {
      return UpdateProfileResult.error('Network error: $e');
    }
  }
}

// ─── Result Model ─────────────────────────────────────────────────────────────

class UpdateProfileResult {
  final bool success;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  const UpdateProfileResult._({
    required this.success,
    this.user,
    this.errorMessage,
  });

  factory UpdateProfileResult.success(Map<String, dynamic> user) =>
      UpdateProfileResult._(success: true, user: user);

  factory UpdateProfileResult.error(String message) =>
      UpdateProfileResult._(success: false, errorMessage: message);
}
