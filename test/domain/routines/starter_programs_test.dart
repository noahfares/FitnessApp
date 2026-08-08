import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/routines/starter_programs.dart';

/// Batch 3.6 — `F-ROU-015`. Guards the exact failure mode the importer
/// exists to avoid: a program referencing an `externalId` the seeded
/// catalogue doesn't have, which would silently rot as the seed list
/// changes over time.
void main() {
  late Set<String> seededExternalIds;

  setUpAll(() {
    final raw = File('assets/seed/exercises.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    seededExternalIds = {
      for (final e in json['exercises'] as List<dynamic>)
        (e as Map<String, dynamic>)['externalId'] as String,
    };
  });

  test('every program is non-empty and has at least one day', () {
    expect(starterPrograms, isNotEmpty);
    for (final program in starterPrograms) {
      expect(program.days, isNotEmpty, reason: program.id);
    }
  });

  test('every program id is unique', () {
    final ids = starterPrograms.map((p) => p.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every exercise reference resolves against the seeded catalogue', () {
    for (final program in starterPrograms) {
      for (final day in program.days) {
        for (final exercise in day.exercises) {
          expect(
            seededExternalIds.contains(exercise.exerciseExternalId),
            isTrue,
            reason:
                '${program.id} / ${day.name}: '
                '${exercise.exerciseExternalId} not in the seed catalogue',
          );
        }
      }
    }
  });

  test('every day has at least one exercise', () {
    for (final program in starterPrograms) {
      for (final day in program.days) {
        expect(
          day.exercises,
          isNotEmpty,
          reason: '${program.id} / ${day.name}',
        );
      }
    }
  });

  test('group keys, where used, are shared by at least two exercises', () {
    for (final program in starterPrograms) {
      for (final day in program.days) {
        final byKey = <String, int>{};
        for (final exercise in day.exercises) {
          if (exercise.groupKey case final key?) {
            byKey[key] = (byKey[key] ?? 0) + 1;
          }
        }
        for (final MapEntry(key: key, value: count) in byKey.entries) {
          expect(
            count,
            greaterThanOrEqualTo(2),
            reason: '${program.id} / ${day.name} groupKey $key',
          );
        }
      }
    }
  });

  test('every program has an attribution and a source URL', () {
    for (final program in starterPrograms) {
      expect(program.attribution, isNotEmpty, reason: program.id);
      expect(
        program.attributionUrl,
        startsWith('https://'),
        reason: program.id,
      );
    }
  });
}
