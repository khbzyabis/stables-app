import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'features/auth/create_stable_screen.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/auth/sign_up_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/verify_screen.dart';
import 'features/home/home_placeholder_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

class MyStablesApp extends StatefulWidget {
  const MyStablesApp({super.key});

  @override
  State<MyStablesApp> createState() => _MyStablesAppState();
}

class _MyStablesAppState extends State<MyStablesApp> {
  final _localeController = LocaleController();

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _localeController,
      child: AnimatedBuilder(
        animation: _localeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'My Stables',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: _localeController.locale,
            supportedLocales: kSupportedLocales,
            localizationsDelegates: const [
              AppL10n.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: SplashScreen.route,
            routes: {
              SplashScreen.route: (_) => const SplashScreen(),
              SignInScreen.route: (_) => const SignInScreen(),
              SignUpScreen.route: (_) => const SignUpScreen(),
              VerifyScreen.route: (_) => const VerifyScreen(),
              CreateStableScreen.route: (_) => const CreateStableScreen(),
              HomePlaceholderScreen.route: (_) => const HomePlaceholderScreen(),
            },
          );
        },
      ),
    );
  }
}
