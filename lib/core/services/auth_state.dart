/// Simple in-memory singleton to hold auth state across screens
class AuthState {
  AuthState._();
  static final AuthState instance = AuthState._();

  String? accessToken;
  String? userId;
  String? email;
  String? role;

  void setFromResponse(Map<String, dynamic> data) {
    accessToken = data['access_token'];
    final user = data['user'] as Map<String, dynamic>;
    userId = user['id']?.toString();
    email = user['email']?.toString();
    role = user['role']?.toString();
  }

  void clear() {
    accessToken = null;
    userId = null;
    email = null;
    role = null;
  }

  bool get isLoggedIn => accessToken != null;

  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
}
