import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/data/db/tables/enums.dart';
import 'package:fitness_app/data/seed/exercise_seeder.dart';

/// Validates the real shipped catalogue (`F-CAT-001`).
///
/// Read from disk rather than the asset bundle so this checks the file that is
/// actually committed. `tools/gen_seed_exercises.py` validates on generation
/// too; this is the belt to that braces, and it fails the build if anyone edits
/// the JSON by hand and gets it wrong.
void main() {
  late SeedPayload payload;

  setUpAll(() {
    final file = File('assets/seed/exercises.json');
    expect(file.existsSync(), isTrue, reason: 'seed asset is missing');
    payload = SeedPayload.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    );
  });

  test('parses, and every record is complete', () {
    // Strict parsing already rejects unknown enum values, so reaching here
    // means every muscle, equipment and tracking type is valid.
    expect(payload.exercises, isNotEmpty);
    expect(payload.seedVersion, greaterThanOrEqualTo(1));

    for (final e in payload.exercises) {
      expect(e.name.trim(), isNotEmpty, reason: e.externalId);
      expect(e.externalId.trim(), isNotEmpty, reason: e.name);
      expect(e.uuid, matches(RegExp(r'^[0-9a-f-]{36}$')), reason: e.name);
    }
  });

  test('identities are unique', () {
    // A duplicate UUID would silently merge two exercises' histories.
    final uuids = payload.exercises.map((e) => e.uuid).toSet();
    final externalIds = payload.exercises.map((e) => e.externalId).toSet();
    final names = payload.exercises.map((e) => e.name).toSet();

    expect(
      uuids,
      hasLength(payload.exercises.length),
      reason: 'duplicate uuid',
    );
    expect(externalIds, hasLength(payload.exercises.length));
    expect(names, hasLength(payload.exercises.length));
  });

  test('no muscle is both primary and secondary on one exercise', () {
    for (final e in payload.exercises) {
      expect(
        e.secondaryMuscles,
        isNot(contains(e.primaryMuscle)),
        reason:
            '${e.name} double-counts ${e.primaryMuscle.name}, which would '
            'inflate its sets-per-muscle figure by 1.5x (F-ANA-005)',
      );
    }
  });

  test('covers every muscle in the taxonomy', () {
    // A muscle with no exercise is a hole in F-ANA-005 that no user could fill
    // without creating a custom exercise.
    final covered = payload.exercises.map((e) => e.primaryMuscle).toSet();
    final missing = Muscle.values.toSet().difference(covered);
    expect(missing, isEmpty, reason: 'no exercise targets: $missing');
  });

  test('covers the tracking types the logger must render', () {
    final types = payload.exercises.map((e) => e.trackingType).toSet();
    expect(types, contains(TrackingType.weightReps));
    expect(types, contains(TrackingType.bodyweightReps));
    expect(types, contains(TrackingType.time));
    expect(types, contains(TrackingType.distanceTime));
  });

  test('is large enough to be usable on first launch', () {
    // Deliberately a starter catalogue, not exhaustive — anything missing is
    // one tap away as a custom exercise (F-CAT-003).
    expect(payload.exercises.length, greaterThanOrEqualTo(80));
  });

  test('provenance is documented', () {
    // Licence risk is the largest legal exposure in the project
    // (docs/10-VISION.md §risks).
    final sources = File('assets/seed/SOURCES.md');
    expect(sources.existsSync(), isTrue);
    expect(sources.readAsStringSync(), contains('Licence'));
  });
}
