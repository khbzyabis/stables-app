import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

import 'api/api_client.dart';
import 'api/api_config.dart';
import 'api/horses_api.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'app_state.dart';
import 'data/analytics.dart';
import 'data/env.dart';
import 'data/session.dart';
import 'data/stable_store.dart';
import 'data/supabase_service.dart';
import 'features/auth/create_stable_screen.dart';
import 'features/auth/portal_gate.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/auth/sign_up_screen.dart';
import 'features/auth/verify_screen.dart';
import 'features/home/home_screen.dart';
import 'features/horses/add_horse_screen.dart';
import 'features/horses/add_tack_item_screen.dart';
import 'features/horses/documents_screen.dart';
import 'features/horses/edit_horse_screen.dart';
import 'features/horses/feed_chart_screen.dart';
import 'features/horses/health_screen.dart';
import 'features/horses/horse_profile_screen.dart';
import 'features/horses/horse_record_screen.dart';
import 'features/horses/progress_screen.dart';
import 'features/horses/setup_changed_screen.dart';
import 'features/horses/setups_screen.dart';
import 'features/horses/tack_box_screen.dart';
import 'features/horses/training_screen.dart';
import 'features/board/board_screen.dart';
import 'features/board/noticeboard_screen.dart';
import 'features/board/post_notice_screen.dart';
import 'features/settings/contacts_screen.dart';
import 'features/settings/help_screen.dart';
import 'features/settings/language_screen.dart';
import 'features/settings/profile_screen.dart';
import 'features/settings/report_problem_screen.dart';
import 'features/settings/set_location_screen.dart';
import 'features/settings/stable_language_screen.dart';
import 'features/settings/stable_settings_screen.dart';
import 'features/shows/show_screen.dart';
import 'features/shows/shows_screen.dart';
import 'features/shows/start_list_screen.dart';
import 'features/market/paid_screen.dart';
import 'features/edge/day_one_screen.dart';
import 'features/edge/horse_pending_screen.dart';
import 'features/edge/invite_accepted_screen.dart';
import 'features/edge/offline_screen.dart';
import 'features/schedule/edit_activity_screen.dart';
import 'features/tasks/kit_screen.dart';
import 'features/schedule/add_activity_screen.dart';
import 'features/schedule/month_screen.dart';
import 'features/schedule/schedule_screen.dart';
import 'features/market/basket_screen.dart';
import 'features/market/compare_quotes_screen.dart';
import 'features/market/declined_screen.dart';
import 'features/market/item_screen.dart';
import 'features/market/market_screen.dart';
import 'features/market/shop_screen.dart';
import 'features/market/order_screen.dart';
import 'features/market/payments_screen.dart';
import 'features/market/provider_screen.dart';
import 'features/market/provider_vendor_screen.dart';
import 'features/market/my_quotes_screen.dart';
import 'features/market/seller_apply_screen.dart';
import 'features/market/seller_dashboard_screen.dart';
import 'features/provider_app/provider_app_screen.dart';
import 'features/admin/admin_screen.dart';
import 'features/admin/console_screen.dart';
import 'features/market/quote_request_screen.dart';
import 'features/market/receipt_screen.dart';
import 'features/people/approvals_screen.dart';
import 'features/people/invite_screen.dart';
import 'features/people/my_stables_screen.dart';
import 'features/people/people_screen.dart';
import 'features/people/roles_screen.dart';
import 'features/tasks/assign_task_screen.dart';
import 'features/tasks/groom_day_screen.dart';
import 'features/tasks/task_progress_screen.dart';
import 'features/transport/booked_journey_screen.dart';
import 'features/transport/request_transport_screen.dart';
import 'features/transport/transport_quotes_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

class MyStablesApp extends StatefulWidget {
  const MyStablesApp({super.key});

  @override
  State<MyStablesApp> createState() => _MyStablesAppState();
}

class _MyStablesAppState extends State<MyStablesApp> {
  final _localeController = LocaleController();
  final _session = AppSession();
  final _navKey = GlobalKey<NavigatorState>();
  // Talk to the real API when one is configured (dart-define API_BASE_URL);
  // otherwise run offline with local sample data.
  final _stableStore = StableStore(
    api: ApiConfig.isConfigured ? HorsesApi(ApiClient()) : null,
  );

  @override
  void initState() {
    super.initState();
    // Keep the session in step with Supabase auth: load stables on sign-in,
    // clear them on sign-out.
    if (SupabaseService.isSignedIn) {
      _session.refresh();
      _identify(SupabaseService.currentUser);
    }
    SupabaseService.authChanges.listen((state) {
      if (state.session != null) {
        _session.refresh();
        _identify(state.session!.user);
      } else {
        _session.clear();
        Analytics.reset();
      }
      // On a real sign-in/sign-out, send the user back through the portal gate
      // so the right door (rider / seller / operator) is re-evaluated.
      final e = state.event;
      if (e == AuthChangeEvent.signedIn || e == AuthChangeEvent.signedOut) {
        _navKey.currentState?.pushNamedAndRemoveUntil(
            PortalGate.route, (r) => false);
      }
    });
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

  void _identify(dynamic user) {
    if (user == null) return;
    final md = user.userMetadata as Map?;
    final name = md?['name'] as String?;
    final email = user.email as String?;
    Analytics.identify(user.id as String, traits: {
      if (email != null && email.isNotEmpty) 'email': email,
      if (name != null && name.isNotEmpty) 'name': name,
    });
  }

  @override
  void dispose() {
    _localeController.dispose();
    _session.dispose();
    _stableStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _localeController,
      child: SessionScope(
        session: _session,
        child: StableScope(
        store: _stableStore,
        child: AnimatedBuilder(
          animation: _localeController,
          builder: (context, _) {
            return MaterialApp(
            title: 'My Stables',
            navigatorKey: _navKey,
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
              navigatorObservers:
                  Env.analyticsEnabled ? [PosthogObserver()] : const [],
              initialRoute: PortalGate.route,
              // The seller (/sell) and operator (/admin) doors resolve to the
              // same gate; it reads Portal.current (set from the URL at boot).
              onGenerateRoute: (settings) {
                if (settings.name == '/sell' || settings.name == '/admin') {
                  return MaterialPageRoute(
                      builder: (_) => const PortalGate(), settings: settings);
                }
                return null;
              },
              routes: {
                PortalGate.route: (_) => const PortalGate(),
                SignInScreen.route: (_) => const SignInScreen(),
                SignUpScreen.route: (_) => const SignUpScreen(),
                VerifyScreen.route: (_) => const VerifyScreen(),
                CreateStableScreen.route: (_) => const CreateStableScreen(),
                HomeScreen.route: (_) => const HomeScreen(),
                AddHorseScreen.route: (_) => const AddHorseScreen(),
                HorseProfileScreen.route: (_) => const HorseProfileScreen(),
                HorseRecordScreen.route: (_) => const HorseRecordScreen(),
                TackBoxScreen.route: (_) => const TackBoxScreen(),
                AddTackItemScreen.route: (_) => const AddTackItemScreen(),
                SetupsScreen.route: (_) => const SetupsScreen(),
                SetupChangedScreen.route: (_) => const SetupChangedScreen(),
                HealthScreen.route: (_) => const HealthScreen(),
                TrainingScreen.route: (_) => const TrainingScreen(),
                FeedChartScreen.route: (_) => const FeedChartScreen(),
                DocumentsScreen.route: (_) => const DocumentsScreen(),
                ProgressScreen.route: (_) => const ProgressScreen(),
                EditHorseScreen.route: (_) => const EditHorseScreen(),
                NoticeboardScreen.route: (_) => const NoticeboardScreen(),
                PostNoticeScreen.route: (_) => const PostNoticeScreen(),
                BoardScreen.route: (_) => const BoardScreen(),
                ContactsScreen.route: (_) => const ContactsScreen(),
                StableSettingsScreen.route: (_) => const StableSettingsScreen(),
                ProfileScreen.route: (_) => const ProfileScreen(),
                LanguageScreen.route: (_) => const LanguageScreen(),
                StableLanguageScreen.route: (_) => const StableLanguageScreen(),
                HelpScreen.route: (_) => const HelpScreen(),
                ReportProblemScreen.route: (_) => const ReportProblemScreen(),
                SetLocationScreen.route: (_) => const SetLocationScreen(),
                ShowsScreen.route: (_) => const ShowsScreen(),
                ShowScreen.route: (_) => const ShowScreen(),
                StartListScreen.route: (_) => const StartListScreen(),
                PaidScreen.route: (_) => const PaidScreen(),
                InviteAcceptedScreen.route: (_) => const InviteAcceptedScreen(),
                HorsePendingScreen.route: (_) => const HorsePendingScreen(),
                EditActivityScreen.route: (_) => const EditActivityScreen(),
                KitScreen.route: (_) => const KitScreen(),
                DayOneScreen.route: (_) => const DayOneScreen(),
                OfflineScreen.route: (_) => const OfflineScreen(),
                ScheduleScreen.route: (_) => const ScheduleScreen(),
                MonthScreen.route: (_) => const MonthScreen(),
                AddActivityScreen.route: (_) => const AddActivityScreen(),
                GroomDayScreen.route: (_) => const GroomDayScreen(),
                AssignTaskScreen.route: (_) => const AssignTaskScreen(),
                TaskProgressScreen.route: (_) => const TaskProgressScreen(),
                MarketScreen.route: (_) => const MarketScreen(),
                ShopScreen.route: (_) => const ShopScreen(),
                ItemScreen.route: (_) => const ItemScreen(),
                BasketScreen.route: (_) => const BasketScreen(),
                OrderScreen.route: (_) => const OrderScreen(),
                ProviderScreen.route: (_) => const ProviderScreen(),
                ProviderVendorScreen.route: (_) =>
                    const ProviderVendorScreen(),
                AdminScreen.route: (_) => const AdminScreen(),
                ConsoleScreen.route: (_) => const ConsoleScreen(),
                MyQuotesScreen.route: (_) => const MyQuotesScreen(),
                SellerApplyScreen.route: (_) => const SellerApplyScreen(),
                SellerDashboardScreen.route: (_) =>
                    const SellerDashboardScreen(),
                ProviderAppScreen.route: (_) => const ProviderAppScreen(),
                QuoteRequestScreen.route: (_) => const QuoteRequestScreen(),
                CompareQuotesScreen.route: (_) => const CompareQuotesScreen(),
                RequestTransportScreen.route: (_) => const RequestTransportScreen(),
                TransportQuotesScreen.route: (_) => const TransportQuotesScreen(),
                BookedJourneyScreen.route: (_) => const BookedJourneyScreen(),
                PaymentsScreen.route: (_) => const PaymentsScreen(),
                ReceiptScreen.route: (_) => const ReceiptScreen(),
                DeclinedScreen.route: (_) => const DeclinedScreen(),
                PeopleScreen.route: (_) => const PeopleScreen(),
                RolesScreen.route: (_) => const RolesScreen(),
                MyStablesScreen.route: (_) => const MyStablesScreen(),
                ApprovalsScreen.route: (_) => const ApprovalsScreen(),
                InviteScreen.route: (_) => const InviteScreen(),
              },
            );
          },
        ),
      ),
      ),
    );
  }
}
