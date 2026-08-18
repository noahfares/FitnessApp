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
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceHover,
    required this.surfaceRaisedHover,
    required this.label,
    required this.labelSecondary,
    required this.labelTertiary,
    required this.separator,
    required this.tint,
    required this.tintHover,
    required this.prSurface,
    required this.prBorder,
    required this.prLabel,
    required this.prBody,
    required this.chartInactive,
    required this.barShaftStart,
    required this.barShaftEnd,
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

  // ─────────────────────────────────────────────────────────────
  // Apple-style surface ladder (docs handoff: "Apple-style appearance").
  // Elevation is lightness in both appearances — never `withOpacity` overlays
  // on a dark background to fake a card.
  // ─────────────────────────────────────────────────────────────

  /// Screen background.
  final Color background;

  /// Grouped cards, stat tiles, segmented track, chips.
  final Color surface;

  /// Controls sitting *on* a [surface] card — rep buttons, stepper circles,
  /// active segmented thumb.
  final Color surfaceRaised;

  /// [surface] card pressed/hover state.
  final Color surfaceHover;

  /// [surfaceRaised] control pressed/hover state.
  final Color surfaceRaisedHover;

  /// Primary text.
  final Color label;

  /// Secondary text, captions, axis labels, section headers.
  final Color labelSecondary;

  /// Chevrons, disabled glyphs.
  final Color labelTertiary;

  /// List row dividers, footer hairline.
  final Color separator;

  /// Primary action, links, active tab, chart line, active volume bar.
  final Color tint;

  /// Primary action pressed/hover.
  final Color tintHover;

  /// PR card background.
  final Color prSurface;

  /// PR card border, 1 px.
  final Color prBorder;

  /// PR heading text, PR axis label, PR delta chip text.
  final Color prLabel;

  /// PR card body text.
  final Color prBody;

  /// Non-highlighted chart bars.
  final Color chartInactive;

  /// Barbell shaft gradient, top stop.
  final Color barShaftStart;

  /// Barbell shaft gradient, bottom stop.
  final Color barShaftEnd;

  static const AppColors light = AppColors(
    success: Color(0xFF1B6E3C),
    onSuccess: Color(0xFFFFFFFF),
    // Apple's systemOrange — "the only celebratory colour", per the design
    // handoff. Distinct enough from `warning` (brown-amber) that a PR and a
    // stall never read as the same kind of thing.
    pr: Color(0xFFFF9500),
    // Black, not white: FF9500 is too light for white text to clear WCAG AA
    // (2.2:1) — the theme test catches that rather than trusting the eye,
    // the same rule that shaped this field before the Apple-style pass.
    onPr: Color(0xFF000000),
    warning: Color(0xFF8A5300),
    onWarning: Color(0xFFFFFFFF),
    danger: Color(0xFFB3261E),
    onDanger: Color(0xFFFFFFFF),
    // ~54% of black: readable in bright light, plainly not entered data.
    ghost: Color(0x8A000000),
    // The first series colour matches `tint` — the common case is one line,
    // and it should read as the app's own accent, not a separate palette.
    chartSeries: [
      Color(0xFF0071E3),
      Color(0xFF1B6E3C),
      Color(0xFFB26A00),
      Color(0xFF8E4EC6),
      Color(0xFF0E7490),
      Color(0xFFB3261E),
    ],
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F5F7),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceHover: Color(0xFFEDEDF0),
    surfaceRaisedHover: Color(0xFFF0F0F3),
    label: Color(0xFF1D1D1F),
    labelSecondary: Color(0xFF86868B),
    labelTertiary: Color(0xFFC7C7CC),
    separator: Color(0xFFF0F0F2),
    tint: Color(0xFF0071E3),
    tintHover: Color(0xFF0077ED),
    prSurface: Color(0xFFFFF7ED),
    prBorder: Color(0xFFFFD9A8),
    prLabel: Color(0xFFC2610A),
    prBody: Color(0xFF8A4A08),
    chartInactive: Color(0xFFC7C7CC),
    barShaftStart: Color(0xFFD2D2D7),
    barShaftEnd: Color(0xFFA1A1A6),
  );

  static const AppColors dark = AppColors(
    success: Color(0xFF6BD68F),
    onSuccess: Color(0xFF00391B),
    // Apple's systemOrange (dark) — brighter and less saturated than the
    // light value, matching the tint's own dark-mode brightening.
    pr: Color(0xFFFF9F0A),
    onPr: Color(0xFF3D2600),
    warning: Color(0xFFFFB95C),
    onWarning: Color(0xFF3D2600),
    danger: Color(0xFFF2B8B5),
    onDanger: Color(0xFF601410),
    // Lifted on dark surfaces: the same 54% would disappear entirely.
    ghost: Color(0x99FFFFFF),
    chartSeries: [
      Color(0xFF0A84FF),
      Color(0xFF6BD68F),
      Color(0xFFFFB95C),
      Color(0xFFCBA6F7),
      Color(0xFF67D8E8),
      Color(0xFFF2B8B5),
    ],
    // Apple's "elevated" dark set (sheets, modal content) — #1C1C1E, never
    // pure black, per docs/24-DESIGN-SYSTEM.md's OLED-scroll-smear rule.
    background: Color(0xFF1C1C1E),
    surface: Color(0xFF2C2C2E),
    surfaceRaised: Color(0xFF3A3A3C),
    surfaceHover: Color(0xFF48484A),
    surfaceRaisedHover: Color(0xFF48484A),
    label: Color(0xFFFFFFFF),
    labelSecondary: Color(0x99EBEBF5),
    labelTertiary: Color(0x4DEBEBF5),
    separator: Color(0xA6545458),
    tint: Color(0xFF0A84FF),
    tintHover: Color(0xFF409CFF),
    prSurface: Color(0x26FF9F0A),
    prBorder: Color(0x73FF9F0A),
    prLabel: Color(0xFFFF9F0A),
    prBody: Color(0xFFFFD9A0),
    chartInactive: Color(0xFF48484A),
    barShaftStart: Color(0xFF8E8E93),
    barShaftEnd: Color(0xFF636366),
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
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceHover,
    Color? surfaceRaisedHover,
    Color? label,
    Color? labelSecondary,
    Color? labelTertiary,
    Color? separator,
    Color? tint,
    Color? tintHover,
    Color? prSurface,
    Color? prBorder,
    Color? prLabel,
    Color? prBody,
    Color? chartInactive,
    Color? barShaftStart,
    Color? barShaftEnd,
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
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    surfaceHover: surfaceHover ?? this.surfaceHover,
    surfaceRaisedHover: surfaceRaisedHover ?? this.surfaceRaisedHover,
    label: label ?? this.label,
    labelSecondary: labelSecondary ?? this.labelSecondary,
    labelTertiary: labelTertiary ?? this.labelTertiary,
    separator: separator ?? this.separator,
    tint: tint ?? this.tint,
    tintHover: tintHover ?? this.tintHover,
    prSurface: prSurface ?? this.prSurface,
    prBorder: prBorder ?? this.prBorder,
    prLabel: prLabel ?? this.prLabel,
    prBody: prBody ?? this.prBody,
    chartInactive: chartInactive ?? this.chartInactive,
    barShaftStart: barShaftStart ?? this.barShaftStart,
    barShaftEnd: barShaftEnd ?? this.barShaftEnd,
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
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceRaisedHover: Color.lerp(
        surfaceRaisedHover,
        other.surfaceRaisedHover,
        t,
      )!,
      label: Color.lerp(label, other.label, t)!,
      labelSecondary: Color.lerp(labelSecondary, other.labelSecondary, t)!,
      labelTertiary: Color.lerp(labelTertiary, other.labelTertiary, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      tintHover: Color.lerp(tintHover, other.tintHover, t)!,
      prSurface: Color.lerp(prSurface, other.prSurface, t)!,
      prBorder: Color.lerp(prBorder, other.prBorder, t)!,
      prLabel: Color.lerp(prLabel, other.prLabel, t)!,
      prBody: Color.lerp(prBody, other.prBody, t)!,
      chartInactive: Color.lerp(chartInactive, other.chartInactive, t)!,
      barShaftStart: Color.lerp(barShaftStart, other.barShaftStart, t)!,
      barShaftEnd: Color.lerp(barShaftEnd, other.barShaftEnd, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  /// Shorthand for the semantic palette.
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
