import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../db/app_database.dart';
import '../db/tables/enums.dart';

/// Seeds the exercise catalogue from `assets/seed/exercises.json`
/// (`F-CAT-001`).
///
/// Runs on first launch and again after any upgrade that ships a new seed
/// version. Matching is on `external_id`, never on name: that is what lets an
/// upstream correction update a row in place rather than creating a duplicate
/// and orphaning every set logged against the old one.
///
/// **User edits always win.** A seeded row the user has changed is never
/// overwritten, so renaming "Bench Press" to "Comp Bench" survives every
/// upgrade.
class ExerciseSeeder {
  const ExerciseSeeder(this._db, {this.assetPath = _defaultAsset});

  static const String _defaultAsset = 'assets/seed/exercises.json';

  final AppDatabase _db;
  final String assetPath;

  /// Seeds if needed. Safe to call on every launch — it is a no-op once the
  /// shipped seed version has been applied.
  Future<SeedResult> seedIfNeeded({required int Function() now}) async {
    final payload = await _loadAsset();
    final shippedVersion = payload.seedVersion;
    final appliedVersion = await _appliedSeedVersion();

    if (appliedVersion >= shippedVersion) {
      return const SeedResult(inserted: 0, updated: 0, skipped: 0);
    }

    final result = await _apply(payload.exercises, now: now);
    await _recordSeedVersion(shippedVersion, now: now);
    return result;
  }

  /// Applies records in a single transaction, so an interrupted seed leaves no
  /// half-populated catalogue.
  Future<SeedResult> _apply(
    List<SeedExercise> records, {
    required int Function() now,
  }) async {
    var inserted = 0, updated = 0, skipped = 0;

    await _db.transaction(() async {
      final existing = <String, Exercise>{
        for (final row in await _db.select(_db.exercises).get())
          if (row.externalId != null) row.externalId!: row,
      };

      for (final record in records) {
        final current = existing[record.externalId];
        final timestamp = now();

        if (current == null) {
          await _db.into(_db.exercises).insert(record.toCompanion(timestamp));
          inserted++;
          continue;
        }

        // Seeding stamps seedUpdatedAt alongside updatedAt, so they match
        // exactly until something else writes the row. Comparing against
        // createdAt instead would work only for the first re-seed.
        final userEdited =
            current.seedUpdatedAt == null ||
            current.updatedAt != current.seedUpdatedAt;
        if (userEdited) {
          skipped++;
          continue;
        }

        await (_db.update(_db.exercises)..where((e) => e.id.equals(current.id)))
            .write(record.toUpdateCompanion(timestamp));
        updated++;
      }
    });

    return SeedResult(inserted: inserted, updated: updated, skipped: skipped);
  }

  Future<int> _appliedSeedVersion() async {
    final row =
        await (_db.select(_db.appSettings)
              ..where((s) => s.key.equals(_seedVersionKey))
              ..where((s) => s.deletedAt.isNull()))
            .getSingleOrNull();
    return row == null ? 0 : int.tryParse(row.value) ?? 0;
  }

  Future<void> _recordSeedVersion(
    int version, {
    required int Function() now,
  }) async {
    final timestamp = now();
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            id: _seedVersionKey,
            key: _seedVersionKey,
            value: '$version',
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
  }

  Future<SeedPayload> _loadAsset() async {
    final raw = await rootBundle.loadString(assetPath);
    return SeedPayload.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static const String _seedVersionKey = 'seed.exercises.version';
}

/// What a seeding pass did. Reported so a silent no-op is distinguishable from
/// a silent failure.
class SeedResult {
  const SeedResult({
    required this.inserted,
    required this.updated,
    required this.skipped,
  });

  final int inserted;

  /// Seeded rows refreshed from the asset because the user had not edited them.
  final int updated;

  /// Seeded rows left alone because the user had edited them.
  final int skipped;

  bool get didAnything => inserted > 0 || updated > 0;

  @override
  String toString() =>
      'SeedResult(inserted: $inserted, updated: $updated, skipped: $skipped)';
}

class SeedPayload {
  const SeedPayload({required this.seedVersion, required this.exercises});

  final int seedVersion;
  final List<SeedExercise> exercises;

  factory SeedPayload.fromJson(Map<String, dynamic> json) => SeedPayload(
    seedVersion: json['seedVersion'] as int,
    exercises: [
      for (final e in json['exercises'] as List<dynamic>)
        SeedExercise.fromJson(e as Map<String, dynamic>),
    ],
  );
}

/// One record from the seed asset.
///
/// Parsing is strict: an unknown muscle or equipment value throws rather than
/// defaulting, because a silently mis-categorised exercise corrupts every
/// sets-per-muscle figure downstream (`F-ANA-005`).
class SeedExercise {
  const SeedExercise({
    required this.uuid,
    required this.externalId,
    required this.name,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.trackingType,
    required this.aliases,
  });

  final String uuid;
  final String externalId;
  final String name;
  final Muscle primaryMuscle;
  final List<Muscle> secondaryMuscles;
  final Equipment equipment;
  final TrackingType trackingType;
  final List<String> aliases;

  factory SeedExercise.fromJson(Map<String, dynamic> json) => SeedExercise(
    uuid: json['uuid'] as String,
    externalId: json['externalId'] as String,
    name: json['name'] as String,
    primaryMuscle: Muscle.values.byName(json['primaryMuscle'] as String),
    secondaryMuscles: [
      for (final m in json['secondaryMuscles'] as List<dynamic>)
        Muscle.values.byName(m as String),
    ],
    equipment: Equipment.values.byName(json['equipment'] as String),
    trackingType: TrackingType.values.byName(json['trackingType'] as String),
    aliases: [for (final a in json['aliases'] as List<dynamic>) a as String],
  );

  /// Only runs on first insert — [toUpdateCompanion] deliberately never
  /// touches `weight_entry_mode`, the same "user edits always win" reasoning
  /// that keeps it off every other user-owned field. This does mean an
  /// **existing** catalogue keeps whatever it already has (`total`, the
  /// column default) even after a re-seed; only a fresh install or a newly
  /// seeded row gets the per-equipment default (`F-LOG-017` §2).
  ExercisesCompanion toCompanion(int timestamp) => ExercisesCompanion.insert(
    id: uuid,
    externalId: Value(externalId),
    name: name,
    primaryMuscle: primaryMuscle,
    secondaryMuscles: Value([for (final m in secondaryMuscles) m.name]),
    equipment: equipment,
    trackingType: trackingType,
    aliases: Value(aliases),
    weightEntryMode: Value(defaultWeightEntryModeFor(equipment)),
    createdAt: timestamp,
    updatedAt: timestamp,
    seedUpdatedAt: Value(timestamp),
  );

  /// Deliberately narrow: refreshes only the fields the catalogue owns, leaving
  /// favourites, sticky notes, rest defaults and archive state untouched.
  ExercisesCompanion toUpdateCompanion(int timestamp) => ExercisesCompanion(
    name: Value(name),
    primaryMuscle: Value(primaryMuscle),
    secondaryMuscles: Value([for (final m in secondaryMuscles) m.name]),
    equipment: Value(equipment),
    trackingType: Value(trackingType),
    aliases: Value(aliases),
    updatedAt: Value(timestamp),
    seedUpdatedAt: Value(timestamp),
  );
}
