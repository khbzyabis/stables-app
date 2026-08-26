import 'package:flutter/material.dart';

import '../../data/portal.dart';
import '../../data/session.dart';
import '../../data/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_button.dart';
import '../admin/console_screen.dart';
import '../home/home_screen.dart';
import '../market/provider_screen.dart';
import 'create_stable_screen.dart';
import 'sign_in_screen.dart';

/// The single entry point for every front door. It reads which portal the URL
/// opened (Portal.current), then:
///   • not signed in  → that portal's sign-in
///   • signed in, right account for the door → the door's home
///   • signed in, wrong account → a polite bounce with the correct link
class PortalGate extends StatefulWidget {
  const PortalGate({super.key});
  static const route = '/';

  @override
  State<PortalGate> createState() => _PortalGateState();
}

class _PortalGateState extends State<PortalGate> {
  @override
  Widget build(BuildContext context) {
    final portal = Portal.current;
    if (!SupabaseService.isSignedIn) {
      return const SignInScreen();
    }
    return FutureBuilder<_GateResult>(
      future: _decide(portal),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final r = snap.data;
        if (r == null || !r.allowed) {
          return _Mismatch(portal: portal, accountType: r?.accountType);
        }
        return r.destination!;
      },
    );
  }

  Future<_GateResult> _decide(AppPortal portal) async {
    if (portal == AppPortal.admin) {
      final ok = await SupabaseService.isAppAdmin();
      return _GateResult(ok, ok ? const ConsoleScreen() : null, 'operator');
    }
    final type = await SupabaseService.myAccountType();
    if (portal == AppPortal.seller) {
      final ok = type == 'seller';
      return _GateResult(ok, ok ? const ProviderScreen() : null, type);
    }
    // app portal — riders and stable people
    final ok = type == 'rider';
    if (!ok) return _GateResult(false, null, type);
    // Decide home vs create/join a stable, once the session has loaded.
    if (!mounted) return _GateResult(true, const HomeScreen(), type);
    final session = SessionScope.of(context);
    await session.refresh();
    final dest = (session.hasStable || session.hasPending)
        ? const HomeScreen()
        : const CreateStableScreen();
    return _GateResult(true, dest, type);
  }
}

class _GateResult {
  _GateResult(this.allowed, this.destination, this.accountType);
  final bool allowed;
  final Widget? destination;
  final String accountType;
}

/// Shown when the signed-in account doesn't belong to the door they opened.
class _Mismatch extends StatelessWidget {
  const _Mismatch({required this.portal, required this.accountType});
  final AppPortal portal;
  final String? accountType;

  String get _doorName => switch (portal) {
        AppPortal.app => 'the rider app',
        AppPortal.seller => 'the seller portal',
        AppPortal.admin => 'the operator console',
      };

  String get _yourDoor => switch (accountType) {
        'seller' => 'This is a seller account — open the seller portal at /sell.',
        'operator' =>
          'This is an operator account — open the operator console at /admin.',
        'rider' => 'This is a rider account — open the app at the main address.',
        _ => 'Use the address that matches your account.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, size: 40, color: AppColors.ink(0.5)),
                  const SizedBox(height: 18),
                  Text('Wrong door', style: AppText.heading(30, height: 1.05)),
                  const SizedBox(height: 12),
                  Text(
                      'This account can\'t sign in to $_doorName. $_yourDoor',
                      style: AppText.body(16,
                          height: 1.5, color: AppColors.ink(0.7))),
                  const SizedBox(height: 28),
                  AppButton(
                    label: 'Sign out',
                    onPressed: () async {
                      await SupabaseService.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
