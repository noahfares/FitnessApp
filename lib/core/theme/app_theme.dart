import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../a11y/motion.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// Material 3 themes, restyled on Apple's product-page and iOS design
/// vocabulary (F-THM-001, F-THM-002, F-THM-005).
///
/// Light and dark are built by the same code path from the same seed. They are
/// equal citizens, not one derived from the other by inversion — both get
/// checked in every review (docs/24-DESIGN-SYSTEM.md).
abstract final class AppTheme {
  /// The single seed colour the whole scheme derives from — Apple's light
  /// `tint` (`AppColors.light.tint`). Restrained on purpose: the design brief
  /// is "chrome recedes, numbers are the interface", so the accent marks
  /// actions and meaning rather than decorating. Changing this one value
  /// re-tints the entire app.
  static const Color seed = Color(0xFF0071E3);

  /// [dynamicScheme] is the wallpaper-derived scheme from `dynamic_color`
  /// (`F-THM-003`), or null to use the fixed Apple palette — off by default,
  /// and the only value on any platform the package doesn't support. The
  /// exact Apple tokens (`AppColors`) only apply when dynamic colour is off;
  /// turning it on reverts surfaces and the accent to the wallpaper-derived
  /// M3 scheme, harmonized against [seed] so a wallpaper extreme cannot
  /// produce a scheme with insufficient contrast.
  static ThemeData light({ColorScheme? dynamicScheme}) =>
      _build(Brightness.light, dynamicScheme);

  static ThemeData dark({ColorScheme? dynamicScheme}) =>
      _build(Brightness.dark, dynamicScheme);

  static ThemeData _build(Brightness brightness, [ColorScheme? dynamicScheme]) {
    final isDark = brightness == Brightness.dark;
    final isFixed = dynamicScheme == null;
    final scheme =
        dynamicScheme?.harmonized() ??
        ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final appColors = isDark ? AppColors.dark : AppColors.light;
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    // Pixel-exact Apple hexes when the tint is fixed; the wallpaper-derived
    // M3 roles when dynamic colour is on — see the [light]/[dark] doc comment.
    final background = isFixed ? appColors.background : scheme.surface;
    final surfaceCard = isFixed
        ? appColors.surface
        : scheme.surfaceContainerLow;
    final accent = isFixed ? appColors.tint : scheme.primary;
    final onAccent = isFixed ? Colors.white : scheme.onPrimary;

    return base.copyWith(
      // Reduce motion is honoured app-wide here rather than route by route
      // (`F-A11Y-005`): routes are declared in one router but pushed from
      // everywhere, and a rule each call site opts into is a rule that decays.
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: ReduceMotionPageTransitionsBuilder(
              base.pageTransitionsTheme.builders[platform] ??
                  const ZoomPageTransitionsBuilder(),
            ),
        },
      ),
      // Never pure black, even in dark mode: OLED smearing during scroll hurts
      // readability, and a set list is scrolled constantly.
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(base.textTheme),
      extensions: [appColors],
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: isFixed ? appColors.label : scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: isFixed ? appColors.separator : scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      // Cards and borders are the exception, not the rule — grouping comes from
      // spacing and typographic hierarchy first. The Apple pass leans into
      // tinted grouped surfaces more heavily than base M3 (see the handoff's
      // "chrome recedes" conflict note); radius follows the handoff's 20 dp.
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceCard,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: AppSpacing.md),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.17,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
    );
  }

  /// Material 3 type scale with Apple's negative letter-spacing and tabular
  /// figures for every numeric display.
  ///
  /// Proportional digits make a column of weights fail to line up vertically,
  /// which reads slowly and looks wrong in a set list where scanning down the
  /// column is the whole point.
  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: _tabular(base.displaySmall), // rest timer
      headlineSmall: base.headlineSmall?.copyWith(letterSpacing: -0.68),
      titleMedium: base.titleMedium,
      bodyLarge: _tabular(base.bodyLarge), // set-row values
      bodySmall: base.bodySmall,
    );
  }

  static TextStyle? _tabular(TextStyle? style) =>
      style?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// Tabular figures for any one-off numeric text not covered by the scale.
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];
}
