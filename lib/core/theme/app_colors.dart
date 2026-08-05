import 'package:flutter/material.dart';

/// Semantic colour roles (docs/24-DESIGN-SYSTEM.md).
///
/// Defined once as a [ThemeExtension] and never as literals in widgets, so that
/// dynamic colour (F-THM-003) and any future palette change cannot break their
/// meaning. `pr` stays celebratory and `danger` stays alarming regardless of
/// what the wallpaper does.
///
/// Read with `Theme.of(context).extension<AppColors>()!`, or the
/// `context.appColors` shorthand below.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.onSuccess,
    required this.pr,
    required this.onPr,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
    required this.ghost,
    required this.chartSeries,
  });

  /// Completed set, achieved target.
  final Color success;
  final Color onSuccess;

  /// Personal record — the only celebratory colour in the app.
  final Color pr;
  final Color onPr;

  /// Missed target, stalled lift, deload suggestion.
  final Color warning;
  final Color onWarning;

  /// Destructive action.
  final Color danger;
  final Color onDanger;

  /// "Last time" prefill text (F-LOG-004).
  ///
  /// The subtlest and most important colour in the app: too faint and it is
  /// invisible under gym lighting, too strong and it reads as entered data.
  /// Needs testing on a real phone in a real gym, not in a simulator.
  final Color ghost;

  /// Ordered categorical chart palette (F-THM-004). Distinguishable without
  /// colour vision, so charts also differentiate by marker shape or dash
  /// pattern (F-A11Y-003).
  final List<Color> chartSeries;

  static const AppColors light = AppColors(
    success: Color(0xFF1B6E3C),
    onSuccess: Color(0xFFFFFFFF),
    // Warmer and more orange than `warning`, which is a brown-amber — the two
    // must not be confusable, since one is a celebration and the other is a
    // problem. An earlier #B26A00 looked right but measured 4.24:1 on white and
    // failed WCAG AA; the theme test catches that rather than trusting the eye.
    pr: Color(0xFFA34D00),
    onPr: Color(0xFFFFFFFF),
    warning: Color(0xFF8A5300),
    onWarning: Color(0xFFFFFFFF),
    danger: Color(0xFFB3261E),
    onDanger: Color(0xFFFFFFFF),
    // ~54% of black: readable in bright light, plainly not entered data.
    ghost: Color(0x8A000000),
    chartSeries: [
      Color(0xFF3E63DD),
      Color(0xFF1B6E3C),
      Color(0xFFB26A00),
      Color(0xFF8E4EC6),
      Color(0xFF0E7490),
      Color(0xFFB3261E),
    ],
  );

  static const AppColors dark = AppColors(
    success: Color(0xFF6BD68F),
    onSuccess: Color(0xFF00391B),
    pr: Color(0xFFFFB95C),
    onPr: Color(0xFF3D2600),
    warning: Color(0xFFFFB95C),
    onWarning: Color(0xFF3D2600),
    danger: Color(0xFFF2B8B5),
    onDanger: Color(0xFF601410),
    // Lifted on dark surfaces: the same 54% would disappear entirely.
    ghost: Color(0x99FFFFFF),
    chartSeries: [
      Color(0xFF8FA8FF),
      Color(0xFF6BD68F),
      Color(0xFFFFB95C),
      Color(0xFFCBA6F7),
      Color(0xFF67D8E8),
      Color(0xFFF2B8B5),
    ],
  );

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? pr,
    Color? onPr,
    Color? warning,
    Color? onWarning,
    Color? danger,
    Color? onDanger,
    Color? ghost,
    List<Color>? chartSeries,
  }) => AppColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    pr: pr ?? this.pr,
    onPr: onPr ?? this.onPr,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    danger: danger ?? this.danger,
    onDanger: onDanger ?? this.onDanger,
    ghost: ghost ?? this.ghost,
    chartSeries: chartSeries ?? this.chartSeries,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      pr: Color.lerp(pr, other.pr, t)!,
      onPr: Color.lerp(onPr, other.onPr, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      ghost: Color.lerp(ghost, other.ghost, t)!,
      chartSeries: [
        for (var i = 0; i < chartSeries.length; i++)
          Color.lerp(
            chartSeries[i],
            i < other.chartSeries.length
                ? other.chartSeries[i]
                : chartSeries[i],
            t,
          )!,
      ],
    );
  }
}

extension AppColorsX on BuildContext {
  /// Shorthand for the semantic palette.
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
