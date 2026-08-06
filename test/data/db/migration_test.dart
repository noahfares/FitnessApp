import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';

/// Migration tests (docs/60-ENGINEERING.md §schema changes).
///
/// Every migration asserts on the **data**, not merely that nothing threw. A
/// migration that runs cleanly and silently drops a column is the failure mode
/// worth catching, and it is invisible to a "did it throw" test.
void main() {
  group('v1 -> v2: exercises.seed_updated_at', () {
    late NativeDatabase executor;
    late QueryExecutor shared;

    setUp(() {
      executor = NativeDatabase.memory();
      shared = executor;
    });

    test('adds the column and preserves existing rows', () async {
      // Build a v1-shaped exercises table by hand, with a row in it.
      final v1 = _RawDatabase(shared);
      await v1.execute('''
        CREATE TABLE exercises (
          id TEXT NOT NULL PRIMARY KEY,
          user_id TEXT NOT NULL DEFAULT 'local-user',
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER NULL,
          external_id TEXT NULL,
          name TEXT NOT NULL,
          aliases TEXT NOT NULL DEFAULT '',
          primary_muscle TEXT NOT NULL,
          secondary_muscles TEXT NOT NULL DEFAULT '',
          equipment TEXT NOT NULL,
          tracking_type TEXT NOT NULL,
          is_custom INTEGER NOT NULL DEFAULT 0,
          is_favorite INTEGER NOT NULL DEFAULT 0,
          archived_at INTEGER NULL,
          notes TEXT NULL,
          default_rest_seconds INTEGER NULL,
          default_bar_id TEXT NULL,
          weight_entry_mode TEXT NOT NULL DEFAULT 'total',
          increment_grams INTEGER NULL,
          bodyweight_coefficient REAL NULL
        )
      ''');
      await v1.execute('''
        INSERT INTO exercises
          (id, created_at, updated_at, external_id, name, primary_muscle,
           equipment, tracking_type, notes, is_favorite)
        VALUES
          ('ex-1', 100, 200, 'barbell-bench-press', 'My Bench', 'chest',
           'barbell', 'weightReps', 'seat height 4', 1)
      ''');
      await v1.execute('PRAGMA user_version = 1');
      await v1.close();

      // Reopening through AppDatabase runs onUpgrade.
      final db = AppDatabase(_reopen(executor));
      addTearDown(db.close);

      final row = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('ex-1'))).getSingle();

      // The user's data survived, all of it.
      expect(row.name, 'My Bench');
      expect(row.notes, 'seat height 4');
      expect(row.isFavorite, isTrue);
      expect(row.createdAt, 100);
      expect(row.updatedAt, 200);
      expect(row.externalId, 'barbell-bench-press');

      // And the new column exists, null for rows that predate it — which is
      // exactly what marks them as "not known to be seed-clean", so re-seeding
      // will leave them alone rather than overwrite an edit.
      expect(row.seedUpdatedAt, isNull);
    });

    test('reaches the current schema version', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.customSelect('SELECT 1').get();
      expect(db.schemaVersion, 2);
    });
  });
}

/// Reuses an already-open executor so the migration sees the v1 database.
QueryExecutor _reopen(QueryExecutor executor) => executor;

/// Minimal raw access for building a historical schema.
class _RawDatabase {
  _RawDatabase(this._executor);

  final QueryExecutor _executor;
  bool _opened = false;

  Future<void> execute(String sql) async {
    if (!_opened) {
      await _executor.ensureOpen(_NoopUser());
      _opened = true;
    }
    await _executor.runCustom(sql, const []);
  }

  Future<void> close() async {}
}

class _NoopUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
