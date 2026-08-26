import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/analytics.dart';
import 'data/env.dart';
import 'data/portal.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean path URLs (/, /sell, /admin) instead of hash URLs, and pick the
  // front door from the address the app was opened at.
  if (kIsWeb) {
    usePathUrlStrategy();
    Portal.current = Portal.fromPath(Uri.base.path);
  }
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  await Analytics.setup();

  // Crash & error reporting. Off until a DSN is set (Env.sentryDsn); when off,
  // the app just runs normally.
  if (Env.sentryEnabled) {
    await SentryFlutter.init(
      (options) {
        options.dsn = Env.sentryDsn;
        // Sample a fifth of transactions for performance; capture all errors.
        options.tracesSampleRate = 0.2;
        // Don't attach personal data (emails, etc.) to events.
        options.sendDefaultPii = false;
      },
      appRunner: () => runApp(const MyStablesApp()),
    );
  } else {
    runApp(const MyStablesApp());
  }
}
