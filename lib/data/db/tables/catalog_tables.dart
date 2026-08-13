import 'package:drift/drift.dart';

import 'enums.dart';
import 'shared.dart';

/// The exercise catalogue. Seeded and user-created rows share one table
/// (`F-CAT-001`, `F-CAT-003`).
class Exercises extends Table with SyncColumns {
  /// The seed dataset's own identifier, so the catalogue can be re-synced or
  /// corrected upstream without duplicating rows or breaking references from
  /// existing sets. Null for custom exercises.
  TextColumn get externalId => text().named('external_id').nullable()();

  TextColumn get name => text()();

  /// Searchable but not displayed — "RDL", "OHP" (`F-CAT-008`).
  TextColumn get aliases =>
      text().map(const StringListConverter()).withDefault(const Constant(''))();

  TextColumn get primaryMuscle => textEnum<Muscle>().named('primary_muscle')();

  TextColumn get secondaryMuscles => text()
      .named('secondary_muscles')
      .map(const StringListConverter())
      .withDefault(const Constant(''))();

  TextColumn get equipment => textEnum<Equipment>()();

  TextColumn get trackingType =>
      textEnum<TrackingType>().named('tracking_type')();

  BoolColumn get isCustom =>
      boolean().named('is_custom').withDefault(const Constant(false))();

  BoolColumn get isFavorite =>
      boolean().named('is_favorite').withDefault(const Constant(false))();

  /// Hidden from pickers (`F-CAT-009`). Distinct from `deletedAt`: archiving is
  /// a user-facing organisational act, deletion is a tombstone.
  IntColumn get archivedAt => integer().named('archived_at').nullable()();

  /// Seat height, pin position, grip width (`F-CAT-007`). Persists across every
  /// session, unlike per-workout notes.
  TextColumn get notes => text().nullable()();

  IntColumn get defaultRestSeconds =>
      integer().named('default_rest_seconds').nullable()();

  TextColumn get defaultBarId =>
      text().named('default_bar_id').nullable().references(Bars, #id)();

  TextColumn get weightEntryMode => textEnum<WeightEntryMode>()
      .named('weight_entry_mode')
      .withDefault(const Constant('total'))();

  /// Smallest sensible jump for this exercise, in canonical grams
  /// (`F-SET-007`).
  IntColumn get incrementGrams =>
      integer().named('increment_grams').nullable()();

  /// Fraction of bodyweight loaded, for `bodyweightReps` (`F-LOG-019`).
  RealColumn get bodyweightCoefficient =>
      real().named('bodyweight_coefficient').nullable()();

  /// Plate-loaded, fixed dumbbells, or a weight stack (`F-PLT-005`). Decides
  /// what the plate calculator shows and what the progression engine's
  /// plate-aware rounding (`F-PRG-012`) snaps a proposal to.
  TextColumn get weightSource => textEnum<WeightSource>()
      .named('weight_source')
      .withDefault(const Constant('plateLoaded'))();

  /// The discrete total weights this exercise's rack actually stocks, for
  /// [WeightSource.fixedIncrement] — real dumbbell racks are not always
  /// evenly spaced, so this is an explicit list rather than a step size.
  /// Canonical grams, storage-is-always-total (`F-LOG-017` §1).
  TextColumn get fixedIncrementsGrams => text()
      .named('fixed_increments_grams')
      .map(const IntListConverter())
      .withDefault(const Constant(''))();

  /// [WeightSource.stack]'s minimum pin weight, canonical grams.
  IntColumn get stackBaseGrams =>
      integer().named('stack_base_grams').nullable()();

  /// [WeightSource.stack]'s jump between pin positions, canonical grams.
  IntColumn get stackStepGrams =>
      integer().named('stack_step_grams').nullable()();

  /// [WeightSource.stack]'s optional add-on magnet, canonical grams — half a
  /// [stackStepGrams] on most machines, but not assumed to be.
  IntColumn get stackHalfStepGrams =>
      integer().named('stack_half_step_grams').nullable()();

  /// User-editable, per-exercise warm-up ramp (`F-LOG-020`) — JSON array of
  /// `{percent, reps}` steps. Null uses the app-wide default ramp.
  TextColumn get warmupRuleset => text().named('warmup_ruleset').nullable()();

  /// The anchor for percentage-based progression (`F-PRG-004`), canonical
  /// grams — set by hand or derived from the exercise's best e1RM
  /// (`F-PRG-010`). Null until the user sets one; a percentage-based rule
  /// falls back to the routine's static target with no training max
  /// configured, the same "nothing to compute from yet" shape every other
  /// rule's first-run case already uses.
  IntColumn get trainingMaxGrams =>
      integer().named('training_max_grams').nullable()();

  /// `updatedAt` as of the last time **seeding** wrote this row.
  ///
  /// Resolves the open question in `F-CAT-001`: a seeded row counts as
  /// user-edited when `updatedAt != seedUpdatedAt`, so re-seeding never
  /// clobbers an edit. Comparing `updatedAt` to `createdAt` instead would work
  /// exactly once — the first re-seed makes them differ and every row then
  /// looks edited forever.
  ///
  /// Null for custom exercises, which seeding never touches.
  IntColumn get seedUpdatedAt =>
      integer().named('seed_updated_at').nullable()();
}

/// Barbells and other loadable implements (`F-PLT-002`).
class Bars extends Table with SyncColumns {
  TextColumn get name => text()();

  /// Canonical grams, like every other mass in the schema (ADR-0003).
  IntColumn get weightGrams => integer().named('weight_grams')();

  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();
}

/// Available plates (`F-PLT-002`). Counts are **pairs**.
class Plates extends Table with SyncColumns {
  IntColumn get weightGrams => integer().named('weight_grams')();

  IntColumn get countAvailable =>
      integer().named('count_available').withDefault(const Constant(0))();

  BoolColumn get isEnabled =>
      boolean().named('is_enabled').withDefault(const Constant(true))();
}
