/// Connection details for the hosted Supabase project. The anon key is a
/// public client key (safe to ship in the app); real protection comes from
/// Row Level Security on the database. Both can be overridden at build time
/// with --dart-define, but sensible defaults are baked in so the web build
/// works out of the box.
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://owyzgqemjmedlwaslhzt.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93eXpncWVtam1lZGx3YXNsaHp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc0MTI5MTYsImV4cCI6MjEwMjk4ODkxNn0.7MohNsJ3oArF93UEyf6KOLZBYMoFVBYaq1AEW1qJh4s',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
