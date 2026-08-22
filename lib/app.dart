import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'api/api_client.dart';
import 'api/api_config.dart';
import 'api/horses_api.dart';
import 'app_state.dart';
import 'data/stable_store.dart';
import 'features/auth/create_stable_screen.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/auth/sign_up_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/verify_screen.dart';
import 'features/home/home_screen.dart';
import 'features/horses/add_horse_screen.dart';
import 'features/horses/horse_profile_screen.dart';
import 'features/schedule/add_activity_screen.dart';
import 'features/schedule/month_screen.dart';
import 'features/schedule/schedule_screen.dart';
import 'features/market/basket_screen.dart';
import 'features/market/item_screen.dart';
import 'features/market/market_screen.dart';
import 'features/tasks/assign_task_screen.dart';
import 'features/tasks/groom_day_screen.dart';
import 'features/tasks/task_progress_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

class MyStablesApp extends StatefulWidget {
  const MyStablesApp({super.key});

  @override
  State<MyStablesApp> createState() => _MyStablesAppState();
}

class _MyStablesAppState extends State<MyStablesApp> {
  final _localeController = LocaleController();
  // Talk to the real API when one is configured (dart-define API_BASE_URL);
  // otherwise run offline with local sample data.
  final _stableStore = StableStore(
    api: ApiConfig.isConfigured ? HorsesApi(ApiClient()) : null,
  );

  @override
  void initState() {
    super.initState();
    // On first launch, honour the device language if it is one we support.
    // A person can still change it in-app; that choice then wins.
    final deviceLocales = WidgetsBinding.instance.platformDispatcher.locales;
    for (final device in deviceLocales) {
      final match = kSupportedLocales.firstWhere(
        (l) => l.languageCode == device.languageCode,
        orElse: () => const Locale('und'),
      );
      if (match.languageCode != 'und') {
        _localeController.setLocale(match);
        break;
      }
    }
  }

  @override
  void dispose() {
    _localeController.dispose();
    _stableStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _localeController,
      child: StableScope(
        store: _stableStore,
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
                HomeScreen.route: (_) => const HomeScreen(),
                AddHorseScreen.route: (_) => const AddHorseScreen(),
                HorseProfileScreen.route: (_) => const HorseProfileScreen(),
                ScheduleScreen.route: (_) => const ScheduleScreen(),
                MonthScreen.route: (_) => const MonthScreen(),
                AddActivityScreen.route: (_) => const AddActivityScreen(),
                GroomDayScreen.route: (_) => const GroomDayScreen(),
                AssignTaskScreen.route: (_) => const AssignTaskScreen(),
                TaskProgressScreen.route: (_) => const TaskProgressScreen(),
                MarketScreen.route: (_) => const MarketScreen(),
                ItemScreen.route: (_) => const ItemScreen(),
                BasketScreen.route: (_) => const BasketScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
