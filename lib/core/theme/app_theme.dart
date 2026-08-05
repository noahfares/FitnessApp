import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Material 3 themes (F-THM-001, F-THM-002, F-THM-005).
///
/// Light and dark are built by the same code path from the same seed. They are
/// equal citizens, not one derived from the other by inversion — both get
/// checked in every review (docs/24-DESIGN-SYSTEM.md).
abstract final class AppTheme {
  /// The single seed colour the whole scheme derives from.
  ///
  /// Restrained on purpose: the design brief is "chrome recedes, numbers are
  /// the interface", so the accent marks actions and meaning rather than
  /// decorating. Changing this one value re-tints the entire app.
  static const Color seed = Color(0xFF3E63DD);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    return base.copyWith(
      // Never pure black, even in dark mode: OLED smearing during scroll hurts
      // readability, and a set list is scrolled constantly.
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _textTheme(base.textTheme),
      extensions: [isDark ? AppColors.dark : AppColors.light],
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      // Cards and borders are the exception, not the rule — grouping comes from
      // spacing and typographic hierarchy first.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: AppSpacing.md),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
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

  /// Material 3 type scale with one deliberate override: **every numeric
  /// display uses tabular figures.**
  ///
  /// Proportional digits make a column of weights fail to line up vertically,
  /// which reads slowly and looks wrong in a set list where scanning down the
  /// column is the whole point.
  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: _tabular(base.displaySmall), // rest timer
      headlineSmall: base.headlineSmall,
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
