/// API connection settings, supplied at build/run time via `--dart-define`:
///
/// ```
/// flutter run \
///   --dart-define=API_BASE_URL=http://localhost:8080 \
///   --dart-define=API_TOKEN=<supabase-jwt> \
///   --dart-define=API_STABLE_ID=<stable-uuid>
/// ```
///
/// When `API_BASE_URL` is empty the app runs in **offline mode** with local
/// sample data, so the preview and first-run experience work without a backend.
/// In production the token comes from Supabase Auth and the stable id from the
/// signed-in person's current membership — not from dart-define.
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment('API_BASE_URL');

  /// A bearer token for development/testing against a running API.
  static const token = String.fromEnvironment('API_TOKEN');

  /// The current stable to scope requests to (dev/testing).
  static const stableId = String.fromEnvironment('API_STABLE_ID');

  /// True when the app should talk to a real backend.
  static bool get isConfigured => baseUrl.isNotEmpty;
}
