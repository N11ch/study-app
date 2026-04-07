/// Central app configuration.
///
/// Flip [useMock] to `false` and set [apiUrl] to your real server
/// before building for production.
class AppConfig {
  AppConfig._();

  // ── Environment toggle ─────────────────────────────────────────────────────

  /// When `true` every service returns fake data; no real HTTP is made.
  /// Flip to `false` when the backend is ready.
  static const bool useMock = true;

  // ── API base URL ───────────────────────────────────────────────────────────

  /// Base URL for all API requests.
  ///
  /// `10.0.2.2` is the Android-emulator alias for `localhost`.
  /// Replace with your real server URL for physical devices / production.
  static const String apiUrl = 'http://10.0.2.2:3000';

  // ── Network settings ───────────────────────────────────────────────────────

  /// How long to wait for a server response before giving up.
  static const Duration requestTimeout = Duration(seconds: 15);

  // ── Legacy shims (remove once all callers are updated) ────────────────────

  /// @deprecated — use [useMock] instead.
  // ignore: non_constant_identifier_names
  static const bool USE_MOCK = useMock;

  /// @deprecated — use [apiUrl] instead.
  // ignore: non_constant_identifier_names
  static const String API_URL = apiUrl;
}
