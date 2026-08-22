import 'package:flutter/widgets.dart';

/// Design tokens for the "Organic" design system, ported verbatim from
/// `_ds/organic-.../styles.css`. This file is the single source of truth for
/// colour, spacing, radius and elevation — retune here.
///
/// Note (per the handoff README): the design system's heading face was changed
/// from Caprasimo to **Gabarito** at the client's request. Body is **Figtree**.
/// Those live in [AppTheme]; this file holds the non-type primitives.
abstract final class AppColors {
  // Core roles.
  static const bg = Color(0xFFF5EAD8); // page ground, every screen
  static const surface = Color(0xFFEBDDC5); // raised surfaces
  static const text = Color(0xFF201E1D); // all body text
  static const accent = Color(0xFFC67139); // terracotta — the single action
  static const accent2 = Color(0xFF7A8A5E); // sage — status, confirmation

  /// Every hairline: ink at 16%.
  static Color get divider => text.withValues(alpha: 0.16);

  // Neutral ramp 100 → 900 (one shared perceptual lightness scale).
  static const neutral100 = Color(0xFFF9F4ED);
  static const neutral200 = Color(0xFFEEE7DB);
  static const neutral300 = Color(0xFFDCD3C4);
  static const neutral400 = Color(0xFFC0B6A5);
  static const neutral500 = Color(0xFFA19786);
  static const neutral600 = Color(0xFF82796A);
  static const neutral700 = Color(0xFF645C50);
  static const neutral800 = Color(0xFF474238);
  static const neutral900 = Color(0xFF2E2B25);

  // Accent (terracotta) ramp.
  static const accent100 = Color(0xFFFFF2EB);
  static const accent200 = Color(0xFFFFE1D0);
  static const accent300 = Color(0xFFFFC6A5);
  static const accent400 = Color(0xFFF6A06B);
  static const accent500 = Color(0xFFD67F48);
  static const accent600 = Color(0xFFB2622D);
  static const accent700 = Color(0xFF8C491A); // body-size accent text (contrast)
  static const accent800 = Color(0xFF643312);
  static const accent900 = Color(0xFF402310);

  // Accent 2 (sage) ramp.
  static const accent2100 = Color(0xFFF0FAE1);
  static const accent2200 = Color(0xFFE1EECC);
  static const accent2300 = Color(0xFFCCDBB2);
  static const accent2400 = Color(0xFFAEBF92);
  static const accent2500 = Color(0xFF8FA073);
  static const accent2600 = Color(0xFF728157);
  static const accent2700 = Color(0xFF56633F);
  static const accent2800 = Color(0xFF3D472B);
  static const accent2900 = Color(0xFF272E1B);

  /// Ink at a given opacity — the design uses text at 50–70% for metadata.
  static Color ink(double opacity) => text.withValues(alpha: opacity);
}

/// Spacing scale: 4.4 / 8.8 / 13.2 / 17.6 / 26.4 / 35.2 px.
abstract final class AppSpace {
  static const s1 = 4.4;
  static const s2 = 8.8;
  static const s3 = 13.2;
  static const s4 = 17.6;
  static const s6 = 26.4;
  static const s8 = 35.2;

  /// Mobile screen padding: 32px horizontal.
  static const screenH = 32.0;

  /// Below the status bar.
  static const screenTop = 84.0;

  /// Bottom safe padding.
  static const screenBottom = 44.0;
}

/// Corner radii: 8 / 16 / 28 px, and a pill for buttons/chips/inputs/switches.
abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 28.0;
  static const pill = 999.0;
}

/// Soft ink-tinted shadows, used sparingly — the system separates with
/// hairlines and space, not cards.
abstract final class AppShadow {
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF2E2B25).withValues(alpha: 0.14),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF2E2B25).withValues(alpha: 0.16),
          offset: const Offset(0, 3),
          blurRadius: 10,
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: const Color(0xFF2E2B25).withValues(alpha: 0.22),
          offset: const Offset(0, 12),
          blurRadius: 32,
        ),
      ];
}
