/// Corner-radius tokens (Apple-style appearance handoff).
///
/// Not on the 4 dp [AppSpacing] scale — radii are a distinct design axis and
/// the handoff specifies them as exact pixel values.
abstract final class AppRadius {
  /// Large grouped card.
  static const double card = 20;

  /// Stat tile, PR card.
  static const double tile = 16;

  /// Rep button, small control.
  static const double control = 12;

  /// Plate.
  static const double plate = 4;
}
