import 'package:flutter/material.dart';

import 'tokens.dart';

/// Typography and [ThemeData] for the app.
///
/// Two families, bundled as variable fonts (see `assets/fonts/` and pubspec):
///  - **Gabarito** — every heading, number and button label. Headings use
///    letter-spacing -0.02em and a tight line height.
///  - **Figtree** — body, labels, metadata.
///
/// The six-language set also needs Arabic (Urdu too), Devanagari (Hindi and
/// Nepali) and Bengali coverage; those Noto faces are listed as fallbacks so
/// any script renders regardless of the primary family.
const List<String> _scriptFallback = [
  'NotoSansArabic',
  'NotoSansDevanagari',
  'NotoSansBengali',
];

abstract final class AppText {
  static List<FontVariation> _wght(FontWeight w) =>
      [FontVariation('wght', w.value.toDouble())];

  /// Gabarito — headings, numbers, button labels.
  static TextStyle heading(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color? color,
    double height = 1.05,
    double letterSpacing = -0.02,
  }) {
    return TextStyle(
      fontFamily: 'Gabarito',
      fontFamilyFallback: _scriptFallback,
      fontSize: size,
      fontWeight: weight,
      fontVariations: _wght(weight),
      height: height,
      letterSpacing: size * letterSpacing,
      color: color ?? AppColors.text,
    );
  }

  /// Figtree — body, labels, metadata.
  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.55,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Figtree',
      fontFamilyFallback: _scriptFallback,
      fontSize: size,
      fontWeight: weight,
      fontVariations: _wght(weight),
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.text,
    );
  }

  /// Uppercase eyebrow label: 12–13px, letter-spacing .1em, sage-700.
  static TextStyle eyebrow({Color? color}) => body(
        12,
        weight: FontWeight.w600,
        letterSpacing: 1.2,
        color: color ?? AppColors.accent2700,
      );

  /// Tag / pill: 11–12px uppercase, wide tracking.
  static TextStyle tag({Color? color}) => body(
        11,
        weight: FontWeight.w600,
        letterSpacing: 0.6,
        color: color ?? AppColors.text,
      );

  /// Metadata: 13–15px at 50–60% opacity.
  static TextStyle meta({double size = 14, double opacity = 0.55}) =>
      body(size, color: AppColors.ink(opacity));
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Figtree',
      fontFamilyFallback: _scriptFallback,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        primary: AppColors.accent,
        secondary: AppColors.accent2,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        brightness: Brightness.light,
      ).copyWith(surfaceTint: Colors.transparent),
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
        fontFamily: 'Figtree',
        fontFamilyFallback: _scriptFallback,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.text, size: 22),
    );
  }
}
