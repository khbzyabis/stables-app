import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Typography and [ThemeData] for the app.
///
/// Two families (Google Fonts):
///  - **Gabarito** 500/600/700 — every heading, number and button label.
///    Headings use letter-spacing -0.02em, tight line height.
///  - **Figtree** 300/400/500/600 — body, labels, metadata.
///
/// Latin script uses Gabarito/Figtree; the six-language set also needs Arabic,
/// Devanagari and Bengali coverage, wired in [localeFontFamily] / [AppText].
abstract final class AppText {
  /// Gabarito — headings, numbers, button labels.
  static TextStyle heading(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color? color,
    double height = 1.05,
    double letterSpacing = -0.02,
  }) {
    return GoogleFonts.gabarito(
      fontSize: size,
      fontWeight: weight,
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
    return GoogleFonts.figtree(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.text,
    );
  }

  /// Uppercase eyebrow label: 12–13px, letter-spacing .1em, sage-700.
  static TextStyle eyebrow({Color? color}) => GoogleFonts.figtree(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: color ?? AppColors.accent2700,
      );

  /// Tag / pill: 11–12px uppercase, wide tracking.
  static TextStyle tag({Color? color}) => GoogleFonts.figtree(
        fontSize: 11,
        fontWeight: FontWeight.w600,
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
      textTheme: GoogleFonts.figtreeTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
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
