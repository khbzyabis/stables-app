import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

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
