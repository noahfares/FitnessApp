/// Personal-record detection (`F-LOG-013`, `docs/40-ANALYTICS-SPEC.md` §4).
///
/// Pure Dart. The caller is responsible for the universal preconditions
/// (§universal-preconditions) — filtering out tombstoned, incomplete, and
/// warm-up sets, and sets missing weight or reps — before calling
/// [detectPrs]. Warm-up sets can never set a record (§4 rule 2), and this
/// module has no way to tell a warm-up from a working set on its own.
library;

import 'e1rm.dart';

/// Mirrors `PrKind` in `lib/data/db/tables/enums.dart` by name — the domain
/// layer may not import that file (`docs/20-ARCHITECTURE.md`), so the two are
/// converted at the repository boundary the same way `SetField`/tracking type
/// names are (`domain/logging/set_fields.dart`).
enum PrDetectionKind { maxWeight, maxRepsAtWeight, bestE1rm, maxSessionVolume }

/// The best value cached for each kind before this set, or null where no
/// record exists yet. [existingMaxRepsAtThisWeight] must already be scoped to
/// the candidate set's exact weight — `maxRepsAtWeight` records are kept one
/// per distinct weight (`docs/21-DATA-MODEL.md` §personal_records `qualifier`).
class ExistingPrs {
  const ExistingPrs({
    this.maxWeightGrams,
    this.existingMaxRepsAtThisWeight,
    this.bestE1rmGrams,
    this.maxSessionVolumeGrams,
  });

  final int? maxWeightGrams;
  final int? existingMaxRepsAtThisWeight;
  final int? bestE1rmGrams;
  final int? maxSessionVolumeGrams;
}

/// One kind of record a set has beaten, and its new value.
class PrHit {
  const PrHit({required this.kind, required this.value, this.qualifierGrams});

  final PrDetectionKind kind;
  final int value;

  /// The weight in grams this record was set at, for `maxRepsAtWeight` only.
  final int? qualifierGrams;
}

/// Display/significance order (§4 rule 5).
const List<PrDetectionKind> prSignificanceOrder = [
  PrDetectionKind.bestE1rm,
  PrDetectionKind.maxWeight,
  PrDetectionKind.maxRepsAtWeight,
  PrDetectionKind.maxSessionVolume,
];

/// Which records a completed set of [weightGrams] × [reps] — contributing
/// [sessionVolumeGrams] to its exercise's running total for the session it
/// belongs to — beats, given [existing]. Empty if none.
///
/// Ties are not records (§4 rule 1): strictly greater only. The result is
/// ordered most-significant-first (§4 rule 5); the UI shows only
/// `results.first` when celebrating a single moment.
List<PrHit> detectPrs({
  required int weightGrams,
  required int reps,
  required int sessionVolumeGrams,
  required ExistingPrs existing,
}) {
  final hits = <PrHit>[];

  final e1rm = epley1Rm(weightGrams: weightGrams, reps: reps);
  if (e1rm != null &&
      (existing.bestE1rmGrams == null || e1rm > existing.bestE1rmGrams!)) {
    hits.add(PrHit(kind: PrDetectionKind.bestE1rm, value: e1rm));
  }

  if (existing.maxWeightGrams == null ||
      weightGrams > existing.maxWeightGrams!) {
    hits.add(PrHit(kind: PrDetectionKind.maxWeight, value: weightGrams));
  }

  if (existing.existingMaxRepsAtThisWeight == null ||
      reps > existing.existingMaxRepsAtThisWeight!) {
    hits.add(
      PrHit(
        kind: PrDetectionKind.maxRepsAtWeight,
        value: reps,
        qualifierGrams: weightGrams,
      ),
    );
  }

  if (existing.maxSessionVolumeGrams == null ||
      sessionVolumeGrams > existing.maxSessionVolumeGrams!) {
    hits.add(
      PrHit(kind: PrDetectionKind.maxSessionVolume, value: sessionVolumeGrams),
    );
  }

  hits.sort(
    (a, b) => prSignificanceOrder
        .indexOf(a.kind)
        .compareTo(prSignificanceOrder.indexOf(b.kind)),
  );
  return hits;
}
