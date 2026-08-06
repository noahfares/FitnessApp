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
