import 'package:drift/drift.dart';

import '../../core/ids/uuid.dart';
import '../../core/units/mass.dart';
import '../db/app_database.dart';

/// Bars and the plate inventory (`F-PLT-002`).
///
/// Same two invariants as every other repository
/// ([`CLAUDE.md`](../../../CLAUDE.md#invariants)): every read filters
/// `deleted_at IS NULL`, every write sets `updated_at`.
class PlateRepository {
  PlateRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  int get _now => _clock().millisecondsSinceEpoch;

  static const String _seededKey = 'seed.plates.done';

  // --- Bars ---------------------------------------------------------------

  Stream<List<Bar>> watchBars() {
    final query = _db.select(_db.bars)..where((b) => b.deletedAt.isNull());
    query.orderBy([(b) => OrderingTerm(expression: b.weightGrams)]);
    return query.watch();
  }

  Future<List<Bar>> getBars() => watchBars().first;

  Future<Bar?> findBarById(String id) => (_db.select(_db.bars)
        ..where((b) => b.id.equals(id))
        ..where((b) => b.deletedAt.isNull()))
      .getSingleOrNull();

  /// The exercise's own bar if it still exists, otherwise the inventory's
  /// default bar, otherwise the heaviest bar available — never throws just
  /// because a `default_bar_id` points at a tombstoned row.
  Future<Bar?> resolveBar(String? exerciseDefaultBarId) async {
    if (exerciseDefaultBarId != null) {
      final own = await findBarById(exerciseDefaultBarId);
      if (own != null) return own;
    }
    final bars = await getBars();
    if (bars.isEmpty) return null;
    return bars.firstWhere(
      (b) => b.isDefault,
      orElse: () => bars.first,
    );
  }

  Future<String> createBar({
    required String id,
    required String name,
    required int weightGrams,
    bool isDefault = false,
  }) async {
    final timestamp = _now;
    if (isDefault) await _clearDefaultBar();
    await _db
        .into(_db.bars)
        .insert(
          BarsCompanion.insert(
            id: id,
            name: name.trim(),
            weightGrams: weightGrams,
            isDefault: Value(isDefault),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
    return id;
  }

  Future<void> updateBar(
    String id, {
    String? name,
    int? weightGrams,
    bool? isDefault,
  }) async {
    if (isDefault == true) await _clearDefaultBar();
    await (_db.update(_db.bars)..where((b) => b.id.equals(id))).write(
      BarsCompanion(
        name: name == null ? const Value.absent() : Value(name.trim()),
        weightGrams: weightGrams == null
            ? const Value.absent()
            : Value(weightGrams),
        isDefault: isDefault == null ? const Value.absent() : Value(isDefault),
        updatedAt: Value(_now),
      ),
    );
  }

  Future<void> deleteBar(String id) async {
    await (_db.update(_db.bars)..where((b) => b.id.equals(id))).write(
      BarsCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
  }

  Future<void> _clearDefaultBar() async {
    await (_db.update(_db.bars)..where((b) => b.isDefault.equals(true))).write(
      BarsCompanion(isDefault: const Value(false), updatedAt: Value(_now)),
    );
  }

  // --- Plates ---------------------------------------------------------------

  Stream<List<Plate>> watchPlates({bool includeDisabled = true}) {
    final query = _db.select(_db.plates)..where((p) => p.deletedAt.isNull());
    if (!includeDisabled) {
      query.where((p) => p.isEnabled.equals(true));
    }
    query.orderBy([(p) => OrderingTerm(expression: p.weightGrams, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<List<Plate>> getPlates({bool includeDisabled = true}) =>
      watchPlates(includeDisabled: includeDisabled).first;

  /// Enabled plates with a nonzero count — what a solve actually has to work
  /// with (`F-PLT-001`).
  Future<List<Plate>> getUsablePlates() async {
    final plates = await getPlates(includeDisabled: false);
    return [
      for (final p in plates)
        if (p.countAvailable > 0) p,
    ];
  }

  Future<String> createPlate({
    required String id,
    required int weightGrams,
    int countAvailable = 0,
    bool isEnabled = true,
  }) async {
    final timestamp = _now;
    await _db
        .into(_db.plates)
        .insert(
          PlatesCompanion.insert(
            id: id,
            weightGrams: weightGrams,
            countAvailable: Value(countAvailable),
            isEnabled: Value(isEnabled),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
    return id;
  }

  Future<void> setPlateCount(String id, int countAvailable) async {
    await (_db.update(_db.plates)..where((p) => p.id.equals(id))).write(
      PlatesCompanion(
        countAvailable: Value(countAvailable),
        updatedAt: Value(_now),
      ),
    );
  }

  Future<void> setPlateEnabled(String id, {required bool isEnabled}) async {
    await (_db.update(_db.plates)..where((p) => p.id.equals(id))).write(
      PlatesCompanion(isEnabled: Value(isEnabled), updatedAt: Value(_now)),
    );
  }

  Future<void> deletePlate(String id) async {
    await (_db.update(_db.plates)..where((p) => p.id.equals(id))).write(
      PlatesCompanion(deletedAt: Value(_now), updatedAt: Value(_now)),
    );
  }

  // --- First-run seed -------------------------------------------------------

  /// Ships sensible bar and plate defaults on first run only, chosen by the
  /// user's load unit at that moment (`F-PLT-002` §1, §3).
  ///
  /// Runs once, gated by an `app_settings` marker — never re-triggered by a
  /// later change to the load unit preference, which would otherwise
  /// silently rewrite a curated inventory out from under whoever set it up.
  Future<void> seedDefaultsIfNeeded(MassUnit unit) async {
    final marker = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_seededKey))
          ..where((s) => s.deletedAt.isNull()))
        .getSingleOrNull();
    if (marker != null) return;

    final timestamp = _now;
    await _db.transaction(() async {
      if (unit == MassUnit.kg) {
        await createBar(
          id: newUuidV4(),
          name: 'Standard barbell',
          weightGrams: 20000,
          isDefault: true,
        );
        await createBar(
          id: newUuidV4(),
          name: "Women's barbell",
          weightGrams: 15000,
        );
        for (final (kg, pairs) in const [
          (25.0, 4),
          (20.0, 2),
          (15.0, 2),
          (10.0, 2),
          (5.0, 2),
          (2.5, 2),
          (1.25, 1),
          (0.5, 1),
          (0.25, 1),
        ]) {
          await createPlate(
            id: newUuidV4(),
            weightGrams: Mass.kg(kg).grams,
            countAvailable: pairs,
          );
        }
      } else {
        await createBar(
          id: newUuidV4(),
          name: 'Standard barbell',
          weightGrams: Mass.lb(45).grams,
          isDefault: true,
        );
        await createBar(
          id: newUuidV4(),
          name: "Women's barbell",
          weightGrams: Mass.lb(35).grams,
        );
        for (final (lb, pairs) in const [
          (45.0, 4),
          (35.0, 2),
          (25.0, 2),
          (10.0, 2),
          (5.0, 2),
          (2.5, 2),
          (1.25, 1),
        ]) {
          await createPlate(
            id: newUuidV4(),
            weightGrams: Mass.lb(lb).grams,
            countAvailable: pairs,
          );
        }
      }

      await _db
          .into(_db.appSettings)
          .insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              id: _seededKey,
              key: _seededKey,
              value: '1',
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );
    });
  }
}
