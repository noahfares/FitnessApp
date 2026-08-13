import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables/enums.dart';

/// The only way features touch the exercise catalogue.
///
/// Two invariants live here so no feature can forget them
/// ([`CLAUDE.md`](../../../CLAUDE.md#invariants)):
///
/// - **Every read filters `deleted_at IS NULL`.** A query that forgets
///   resurrects deleted rows, which looks like a data-integrity bug rather than
///   a missing `WHERE`.
/// - **Every write sets `updated_at`.**
class ExerciseRepository {
  ExerciseRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  int get _now => _clock().millisecondsSinceEpoch;

  /// Live catalogue, alphabetical. Archived and deleted rows are excluded.
  ///
  /// A stream rather than a future so the UI re-renders on any write without
  /// anyone remembering to refresh it (docs/20-ARCHITECTURE.md).
  Stream<List<Exercise>> watchAll({bool includeArchived = false}) {
    final query = _db.select(_db.exercises)
      ..where((e) => e.deletedAt.isNull())
      ..orderBy([(e) => OrderingTerm(expression: e.name)]);
    if (!includeArchived) {
      query.where((e) => e.archivedAt.isNull());
    }
    return query.watch();
  }

  Future<List<Exercise>> getAll({bool includeArchived = false}) =>
      watchAll(includeArchived: includeArchived).first;

  Future<Exercise?> findById(String id) {
    return (_db.select(_db.exercises)
          ..where((e) => e.id.equals(id))
          ..where((e) => e.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Creates a custom exercise (`F-CAT-003`).
  ///
  /// Unlimited, and indistinguishable from a seeded exercise in use — this is
  /// the single most commonly paywalled feature in competitors.
  ///
  /// [id] is caller-supplied so the UI can generate it before the insert
  /// completes and render optimistically (ADR-0008).
  Future<Exercise> createCustom({
    required String id,
    required String name,
    required Muscle primaryMuscle,
    required Equipment equipment,
    required TrackingType trackingType,
    List<Muscle> secondaryMuscles = const [],
    List<String> aliases = const [],
    String? notes,
    int? defaultRestSeconds,
    String? defaultBarId,
    WeightEntryMode? weightEntryMode,
    int? incrementGrams,
    WeightSource? weightSource,
    List<int> fixedIncrementsGrams = const [],
    int? stackBaseGrams,
    int? stackStepGrams,
    int? stackHalfStepGrams,
  }) async {
    final timestamp = _now;
    await _db
        .into(_db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: id,
            name: name.trim(),
            primaryMuscle: primaryMuscle,
            equipment: equipment,
            trackingType: trackingType,
            secondaryMuscles: Value([for (final m in secondaryMuscles) m.name]),
            aliases: Value(aliases),
            notes: Value(notes),
            defaultRestSeconds: Value(defaultRestSeconds),
            defaultBarId: Value(defaultBarId),
            weightEntryMode: Value(
              weightEntryMode ?? defaultWeightEntryModeFor(equipment),
            ),
            // Null falls through to the equipment default (`F-SET-007`,
            // `domain/logging/weight_steps.dart`), never zero.
            incrementGrams: Value(incrementGrams),
            weightSource: Value(
              weightSource ?? defaultWeightSourceFor(equipment),
            ),
            fixedIncrementsGrams: Value(fixedIncrementsGrams),
            stackBaseGrams: Value(stackBaseGrams),
            stackStepGrams: Value(stackStepGrams),
            stackHalfStepGrams: Value(stackHalfStepGrams),
            isCustom: const Value(true),
            createdAt: timestamp,
            updatedAt: timestamp,
            // Deliberately null: seeding must never touch a custom row.
          ),
        );
    return (await findById(id))!;
  }

  /// Names are not unique — "Bench Press (Smith)" is legitimate — so this
  /// informs a warning rather than blocking (`F-CAT-003`).
  Future<bool> nameExists(String name, {String? excludingId}) async {
    final query = _db.select(_db.exercises)
      ..where((e) => e.name.lower().equals(name.trim().toLowerCase()))
      ..where((e) => e.deletedAt.isNull());
    if (excludingId != null) {
      query.where((e) => e.id.equals(excludingId).not());
    }
    return (await query.get()).isNotEmpty;
  }

  Future<void> update(String id, ExercisesCompanion changes) async {
    await (_db.update(_db.exercises)..where((e) => e.id.equals(id))).write(
      changes.copyWith(updatedAt: Value(_now)),
    );
  }

  /// The persistent per-exercise note — seat height, pin position, grip width
  /// (`F-CAT-007`). Distinct from per-session notes.
  Future<void> setNotes(String id, String? notes) =>
      update(id, ExercisesCompanion(notes: Value(notes)));

  Future<void> setFavorite(String id, {required bool isFavorite}) =>
      update(id, ExercisesCompanion(isFavorite: Value(isFavorite)));

  /// Hides from pickers without touching history (`F-CAT-009`).
  ///
  /// Distinct from deletion: archiving is a user-facing organisational act.
  Future<void> setArchived(String id, {required bool isArchived}) => update(
    id,
    ExercisesCompanion(archivedAt: Value(isArchived ? _now : null)),
  );

  /// Archives (or restores) every non-archived exercise using [equipment] in
  /// one action — for someone who has lost access to a cable machine, say
  /// (`F-CAT-009` §4). Already-archived rows for other reasons are left
  /// alone by [setArchived]'s own idempotence; this only ever widens the
  /// archived set, it does not restore anything.
  Future<int> bulkArchiveByEquipment(Equipment equipment) async {
    final timestamp = _now;
    return (_db.update(_db.exercises)
          ..where((e) => e.equipment.equalsValue(equipment))
          ..where((e) => e.deletedAt.isNull())
          ..where((e) => e.archivedAt.isNull()))
        .write(
          ExercisesCompanion(
            archivedAt: Value(timestamp),
            updatedAt: Value(timestamp),
          ),
        );
  }

  /// Tombstones the row. **Nothing is ever hard-deleted** (ADR-0008), so this
  /// is reversible by [restore] and never orphans a logged set.
  Future<void> delete(String id) =>
      update(id, ExercisesCompanion(deletedAt: Value(_now)));

  Future<void> restore(String id) =>
      update(id, const ExercisesCompanion(deletedAt: Value(null)));

  /// Whether any set references this exercise — deleted sets included, since
  /// they are restorable.
  Future<bool> hasHistory(String id) async {
    final rows = await _db
        .customSelect(
          'SELECT 1 FROM workout_exercises WHERE exercise_id = ? LIMIT 1',
          variables: [Variable<String>(id)],
        )
        .get();
    return rows.isNotEmpty;
  }
}
