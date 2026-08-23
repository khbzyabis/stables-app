import 'package:sentry_flutter/sentry_flutter.dart';

import 'env.dart';

/// Reports a *handled* error — one we caught and showed the user (e.g. a failed
/// save) — to Sentry, so those are visible alongside crashes. No-op when Sentry
/// is off, and it never throws itself.
class AppErrors {
  static void report(Object error, [StackTrace? stack]) {
    if (!Env.sentryEnabled) return;
    Sentry.captureException(error, stackTrace: stack)
        .catchError((_) => SentryId.empty());
  }
}
