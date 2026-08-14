/// Which inputs a set row renders, driven by the exercise's tracking type
/// (`F-LOG-003` §1, `F-CAT-002`).
///
/// Pure Dart. The tracking type arrives as its stored **name** rather than the
/// `TrackingType` enum, because that enum lives in `lib/data/db/tables/` and
/// the domain layer may not import it (docs/20-ARCHITECTURE.md). The mapping
/// belongs here rather than in a widget: it decides which columns exist, which
/// is a rule about the data, not about the pixels.
library;

/// One measurable column on a set row.
enum SetField {
  /// Canonical grams, always total load.
  weight,
  reps,

  /// Canonical metres.
  distance,

  /// Canonical seconds.
  duration,
}

/// The fields a set of [trackingType] is logged with, in display order.
///
/// An unrecognised type — a row written by a newer version — falls back to
/// weight × reps rather than rendering an unloggable row. A set that cannot be
/// entered is worse than one entered against the wrong columns.
List<SetField> setFieldsFor(String trackingType) => switch (trackingType) {
  'weightReps' => const [SetField.weight, SetField.reps],
  // Weight here is *added* weight, not total — the exercise's own bodyweight
  // coefficient plus the session's captured bodyweight make up the rest of
  // the effective load (`F-LOG-019`).
  'bodyweightReps' => const [SetField.weight, SetField.reps],
  'reps' => const [SetField.reps],
  'time' => const [SetField.duration],
  'distanceTime' => const [SetField.distance, SetField.duration],
  'weightTime' => const [SetField.weight, SetField.duration],
  _ => const [SetField.weight, SetField.reps],
};
