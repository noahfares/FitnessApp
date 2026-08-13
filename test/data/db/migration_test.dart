import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/db/tables/enums.dart';

/// Migration tests (docs/60-ENGINEERING.md §schema changes).
///
/// Every migration asserts on the **data**, not merely that nothing threw. A
/// migration that runs cleanly and silently drops a column is the failure mode
/// worth catching, and it is invisible to a "did it throw" test.
///
/// These run against a **file**, not `NativeDatabase.memory()`. Handing the
/// same in-memory executor to a second `AppDatabase` does not reopen anything —
/// the delegate is already open, so drift skips its opening logic and no
/// migration runs at all. A test written that way passes without ever
/// exercising the thing it names, which is worse than having no test.
void main() {
  late Directory directory;
  late File file;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('fitness_migration');
    file = File('${directory.path}/app.db');
  });

  tearDown(() => directory.deleteSync(recursive: true));

  /// Materialises the database at [version] by creating the current schema and
  /// undoing what has changed since.
  ///
  /// Cheaper and far less error-prone than hand-writing historical DDL, and it
  /// cannot drift from the real schema the way a copied `CREATE TABLE` does.
  Future<void> buildHistoricalDatabase(
    int version, {
    List<String> then = const [],
  }) async {
    final current = AppDatabase(NativeDatabase(file));
    await current.customSelect('SELECT 1').get();
    await current.close();

    final raw = NativeDatabase(file);
    await raw.ensureOpen(_NoopUser());

    if (version < 5) {
      // v5 added exercises.warmup_ruleset (`F-LOG-020`).
      await raw.runCustom('ALTER TABLE exercises DROP COLUMN warmup_ruleset');
    }
    if (version < 4) {
      // v4 added exercises.weight_source and its four weight-source-specific
      // columns (`F-PLT-005`).
      await raw.runCustom('ALTER TABLE exercises DROP COLUMN weight_source');
      await raw.runCustom(
        'ALTER TABLE exercises DROP COLUMN fixed_increments_grams',
      );
      await raw.runCustom('ALTER TABLE exercises DROP COLUMN stack_base_grams');
      await raw.runCustom('ALTER TABLE exercises DROP COLUMN stack_step_grams');
      await raw.runCustom(
        'ALTER TABLE exercises DROP COLUMN stack_half_step_grams',
      );
    }
    if (version < 3) {
      // v3 added only this index.
      await raw.runCustom(
        'DROP INDEX IF EXISTS idx_workouts_single_in_progress',
      );
    }
    if (version < 2) {
      // v2 added only this column.
      await raw.runCustom('ALTER TABLE exercises DROP COLUMN seed_updated_at');
    }
    for (final statement in then) {
      await raw.runCustom(statement, const []);
    }
    await raw.runCustom('PRAGMA user_version = $version');
    await raw.close();
  }

  Future<AppDatabase> reopen() async {
    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();
    return db;
  }

  Future<List<String>> columnsOf(AppDatabase db, String table) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return [for (final row in rows) row.read<String>('name')];
  }

  group('v1 -> v2: exercises.seed_updated_at', () {
    test('adds the column and preserves existing rows', () async {
      await buildHistoricalDatabase(
        1,
        then: [
          '''
          INSERT INTO exercises
            (id, created_at, updated_at, external_id, name, primary_muscle,
             equipment, tracking_type, notes, is_favorite)
          VALUES
            ('ex-1', 100, 200, 'barbell-bench-press', 'My Bench', 'chest',
             'barbell', 'weightReps', 'seat height 4', 1)
          ''',
        ],
      );

      final db = await reopen();

      // Asserted against the table itself, not through the row class: drift
      // maps a *missing* nullable column to null just as happily as a present
      // one, so reading `seedUpdatedAt` cannot tell the two apart.
      expect(await columnsOf(db, 'exercises'), contains('seed_updated_at'));

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

      // Null for rows that predate it — which is exactly what marks them as
      // "not known to be seed-clean", so re-seeding leaves them alone rather
      // than overwriting an edit.
      expect(row.seedUpdatedAt, isNull);
    });
  });

  group('v2 -> v3: at most one workout in progress', () {
    String insertWorkout(String id, int startedAt) =>
        "INSERT INTO workouts (id, created_at, updated_at, name, started_at, "
        "started_at_tz_offset_minutes) "
        "VALUES ('$id', 1, 1, 'Session $id', $startedAt, 0)";

    test(
      'closes out all but the most recent rather than failing to open',
      () async {
        // A database written at v2 could legitimately hold several open sessions;
        // the unique index cannot be created over them. An app that cannot open
        // its own database is a far worse outcome than an auto-closed session.
        await buildHistoricalDatabase(
          2,
          then: [
            insertWorkout('w-0', 1000),
            insertWorkout('w-1', 2000),
            insertWorkout('w-2', 3000),
          ],
        );

        final db = await reopen();

        final open = await db
            .customSelect(
              'SELECT id FROM workouts '
              'WHERE ended_at IS NULL AND deleted_at IS NULL',
            )
            .get();
        expect(open, hasLength(1));
        // The most recently started survives — it is the one plausibly still
        // being trained.
        expect(open.single.read<String>('id'), 'w-2');

        // The others were *ended*, not deleted. Nothing is ever hard-deleted, and
        // a session someone actually trained still belongs in their history.
        final all = await db
            .customSelect(
              'SELECT COUNT(*) AS n FROM workouts WHERE deleted_at IS NULL',
            )
            .getSingle();
        expect(all.read<int>('n'), 3);
      },
    );

    test(
      'the database itself then refuses a second in-progress workout',
      () async {
        await buildHistoricalDatabase(2, then: [insertWorkout('w-0', 1000)]);
        final db = await reopen();

        // The acceptance criterion in F-LOG-001: enforced at the database level,
        // not merely by whichever repository happens to sit in front of it.
        await expectLater(
          db.customStatement(insertWorkout('w-new', 9999)),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('an ended workout is no obstacle to starting the next one', () async {
      await buildHistoricalDatabase(2, then: [insertWorkout('w-0', 1000)]);
      final db = await reopen();

      await db.customStatement(
        'UPDATE workouts SET ended_at = 5000 WHERE id = ?',
        ['w-0'],
      );
      // The constraint is on *in-progress* rows only — a partial index. A plain
      // unique index here would let someone train exactly once.
      await db.customStatement(insertWorkout('w-1', 6000));

      final open = await db
          .customSelect('SELECT id FROM workouts WHERE ended_at IS NULL')
          .get();
      expect(open, hasLength(1));
      expect(open.single.read<String>('id'), 'w-1');
    });
  });

  group('v3 -> v4: exercises weight source', () {
    test(
      'adds the columns, defaulting existing rows to plate-loaded',
      () async {
        await buildHistoricalDatabase(
          3,
          then: [
            '''
          INSERT INTO exercises
            (id, created_at, updated_at, name, primary_muscle, equipment,
             tracking_type)
          VALUES
            ('ex-1', 100, 200, 'Bench Press', 'chest', 'barbell', 'weightReps')
          ''',
          ],
        );

        final db = await reopen();
        final columns = await columnsOf(db, 'exercises');
        expect(columns, contains('weight_source'));
        expect(columns, contains('fixed_increments_grams'));
        expect(columns, contains('stack_base_grams'));
        expect(columns, contains('stack_step_grams'));
        expect(columns, contains('stack_half_step_grams'));

        final row = await (db.select(
          db.exercises,
        )..where((e) => e.id.equals('ex-1'))).getSingle();

        // Every exercise behaved as plate-loaded before this column existed —
        // the default preserves that behaviour for existing rows exactly.
        expect(row.weightSource, WeightSource.plateLoaded);
        expect(row.fixedIncrementsGrams, isEmpty);
        expect(row.stackBaseGrams, isNull);
        expect(row.name, 'Bench Press');
      },
    );
  });

  group('v4 -> v5: exercises warmup ruleset', () {
    test(
      'adds the column, defaulting existing rows to the app-wide ramp',
      () async {
        await buildHistoricalDatabase(
          4,
          then: [
            '''
          INSERT INTO exercises
            (id, created_at, updated_at, name, primary_muscle, equipment,
             tracking_type)
          VALUES
            ('ex-1', 100, 200, 'Bench Press', 'chest', 'barbell', 'weightReps')
          ''',
          ],
        );

        final db = await reopen();
        expect(await columnsOf(db, 'exercises'), contains('warmup_ruleset'));

        final row = await (db.select(
          db.exercises,
        )..where((e) => e.id.equals('ex-1'))).getSingle();

        // Null for existing rows — exactly what falls through to the app-wide
        // default ramp, so no exercise behaves differently after this column
        // existed until someone actually edits it.
        expect(row.warmupRuleset, isNull);
        expect(row.name, 'Bench Press');
      },
    );
  });

  test('a fresh database is created at the current version', () async {
    final db = await reopen();
    expect(db.schemaVersion, 5);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 5);
  });
}

/// Minimal executor user for raw access to a historical database.
class _NoopUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
