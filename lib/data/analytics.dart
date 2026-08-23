import 'package:posthog_flutter/posthog_flutter.dart';

import 'env.dart';

/// Thin wrapper over PostHog. Every call is guarded so analytics never breaks
/// the app: if the key is unset or a call throws, it silently no-ops.
class Analytics {
  /// Native setup (Android/iOS). On web, PostHog is initialised by the snippet
  /// in web/index.html, so this is a no-op there.
  static Future<void> setup() async {
    if (!Env.analyticsEnabled) return;
    try {
      final config = PostHogConfig(Env.posthogKey)
        ..host = Env.posthogHost
        ..captureApplicationLifecycleEvents = true
        ..personProfiles = PostHogPersonProfiles.identifiedOnly;
      await Posthog().setup(config);
    } catch (_) {}
  }

  static void capture(String event, [Map<String, Object>? properties]) {
    if (!Env.analyticsEnabled) return;
    try {
      Posthog().capture(eventName: event, properties: properties);
    } catch (_) {}
  }

  static void identify(String userId, {Map<String, Object>? traits}) {
    if (!Env.analyticsEnabled) return;
    try {
      Posthog().identify(userId: userId, userProperties: traits);
    } catch (_) {}
  }

  static void reset() {
    if (!Env.analyticsEnabled) return;
    try {
      Posthog().reset();
    } catch (_) {}
  }
}
