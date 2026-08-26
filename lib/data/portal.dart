/// The three front doors of My Stables. One app, one backend — the entry URL
/// decides which sign-in a person sees and where they land.
///
///   /        AppPortal.app     riders, owners, grooms, vets, managers
///   /sell    AppPortal.seller  shops, farriers, vets, physios, transport
///   /admin   AppPortal.admin   the platform operator
enum AppPortal { app, seller, admin }

class Portal {
  /// Set once at startup from the browser URL (see main.dart). Defaults to the
  /// rider app on mobile / when no path matches.
  static AppPortal current = AppPortal.app;

  static AppPortal fromPath(String path) {
    if (path.startsWith('/admin')) return AppPortal.admin;
    if (path.startsWith('/sell')) return AppPortal.seller;
    return AppPortal.app;
  }

  /// The account_type this portal expects (admin is gated by is_app_admin
  /// instead, so it has no rider/seller type).
  static String? expectedAccountType(AppPortal p) => switch (p) {
        AppPortal.app => 'rider',
        AppPortal.seller => 'seller',
        AppPortal.admin => null,
      };

  static String signupAccountType(AppPortal p) => switch (p) {
        AppPortal.seller => 'seller',
        _ => 'rider',
      };

  /// Whether this door offers public sign-up (admin is invite-only).
  static bool allowsSignup(AppPortal p) => p != AppPortal.admin;

  static String title(AppPortal p) => switch (p) {
        AppPortal.app => 'My Stables',
        AppPortal.seller => 'My Stables — Sellers',
        AppPortal.admin => 'My Stables — Operator',
      };

  /// One-line pitch under the sign-in heading, per door.
  static String tagline(AppPortal p) => switch (p) {
        AppPortal.app => 'Sign in to your stables.',
        AppPortal.seller =>
          'Sign in to your shop — manage orders, listings and payouts.',
        AppPortal.admin => 'Operator sign-in.',
      };
}
