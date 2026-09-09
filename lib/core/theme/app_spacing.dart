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

  /// The set row's two fixed columns: the number/type cell, and the note
  /// marker. Fixed so that weight, reps and the completion toggle never shrink
  /// because a set happens to carry a note (`F-LOG-023`).
  static const double setNumberColumn = 44;
  static const double setNoteColumn = 32;

  /// The RPE badge, shown only when the setting is on (`F-LOG-014` §3) — it
  /// is not one of the two fixed columns above because most rows never render
  /// it at all.
  static const double setRpeColumn = 36;

  /// The live volume cell (`F-LOG-024`). Fixed width like the number and
  /// note columns: it always renders, so the weight/reps cells beside it must
  /// not shift width as its digit count changes mid-edit.
  static const double setVolumeColumn = 56;
}
