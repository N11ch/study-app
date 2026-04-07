/// Simple in-memory singleton that holds authenticated user state.
///
/// Populated by [AuthService] after a successful login / register.
/// Cleared by [AuthService.logout].
class AuthState {
  AuthState._();
  static final AuthState instance = AuthState._();

  String? accessToken;
  String? userId;
  String? email;
  String? role;
  String? fullName;

  // ---------------------------------------------------------------------------
  // Hydrate from a server response
  // ---------------------------------------------------------------------------

  /// Expects the shape:
  /// ```json
  /// {
  ///   "access_token": "...",
  ///   "user": { "id": "...", "email": "...", "role": "...", "full_name": "..." }
  /// }
  /// ```
  void setFromResponse(Map<String, dynamic> data) {
    accessToken = data['access_token']?.toString();

    final user = data['user'] as Map<String, dynamic>? ?? {};
    userId   = user['id']?.toString();
    email    = user['email']?.toString();
    role     = user['role']?.toString();
    fullName = user['full_name']?.toString()   // backend sends snake_case
            ?? user['fullName']?.toString()    // camelCase fallback
            ?? user['name']?.toString();       // generic fallback
  }

  // ---------------------------------------------------------------------------
  // Clear on logout
  // ---------------------------------------------------------------------------

  void clear() {
    accessToken = null;
    userId      = null;
    email       = null;
    role        = null;
    fullName    = null;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool get isLoggedIn => accessToken != null;

  /// Ready-to-use headers for every authenticated HTTP request.
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

  /// Display name — falls back gracefully so the UI never shows "null".
  String get displayName => fullName ?? email?.split('@').first ?? 'Student';
}
