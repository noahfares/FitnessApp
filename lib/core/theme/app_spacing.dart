/// Spacing and sizing tokens (docs/24-DESIGN-SYSTEM.md).
///
/// 4 dp base unit. Use these rather than bare numbers so spacing stays
/// consistent and adjustable in one place.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Standard screen edge padding.
  static const double screen = lg;

  /// Material's minimum touch target.
  static const double minTouchTarget = 48;

  /// Set-row controls get more, because they are hit mid-set with imprecise,
  /// sweaty aim (F-A11Y-004). Missing a checkbox with a rest clock running is
  /// the interaction failure that matters most in this app.
  static const double setRowTouchTarget = 56;
}
