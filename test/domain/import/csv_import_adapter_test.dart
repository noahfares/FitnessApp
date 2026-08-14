import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/domain/import/csv_import_adapter.dart';

/// Batch 5.3 — `F-DAT-005`, `F-DAT-006`.
void main() {
  const converter = CsvToListConverter(eol: '\n');

  group('Strong CSV', () {
    const adapter = CsvImportAdapter(strongColumnMapping);

    test('parses workouts, sets and reps with the unit named in the header', () {
      const csv =
          'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,RPE,Notes\n'
          '2026-01-01 08:00:00,Push Day,Bench Press,1,100,5,8,Felt good\n'
          '2026-01-01 08:00:00,Push Day,Bench Press,2,102.5,5,,\n'
          '2026-01-01 08:00:00,Push Day,Overhead Press,1,50,8,,\n';

      final result = adapter.parse(converter.convert(csv));

      expect(result.sourceUnitSymbol, 'kg');
      expect(result.sets, hasLength(3));
      expect(result.sets[0].exerciseName, 'Bench Press');
      expect(result.sets[0].weight, 100);
      expect(result.sets[0].reps, 5);
      expect(result.sets[0].rpe, 8);
      expect(result.sets[0].notes, 'Felt good');
      expect(result.sets[2].exerciseName, 'Overhead Press');
    });

    test('marks a "W" set order as a warm-up', () {
      const csv =
          'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps\n'
          '2026-01-01 08:00:00,Push Day,Bench Press,W1,60,5\n'
          '2026-01-01 08:00:00,Push Day,Bench Press,1,100,5\n';

      final result = adapter.parse(converter.convert(csv));

      expect(result.sets[0].isWarmup, isTrue);
      expect(result.sets[0].setOrder, 1);
      expect(result.sets[1].isWarmup, isFalse);
    });

    test('throws on a file missing required columns', () {
      const csv = 'Date,Exercise Name\n2026-01-01,Bench Press\n';

      expect(
        () => adapter.parse(converter.convert(csv)),
        throwsA(isA<UnrecognisedCsvFormatException>()),
      );
    });

    test('throws AmbiguousUnitException when no unit is named anywhere', () {
      const csv =
          'Date,Workout Name,Exercise Name,Set Order,Weight,Reps\n'
          '2026-01-01 08:00:00,Push Day,Bench Press,1,100,5\n';

      expect(
        () => adapter.parse(converter.convert(csv)),
        throwsA(isA<AmbiguousUnitException>()),
      );
    });

    test('accepts an explicit unit override after an ambiguous file', () {
      const csv =
          'Date,Workout Name,Exercise Name,Set Order,Weight,Reps\n'
          '2026-01-01 08:00:00,Push Day,Bench Press,1,100,5\n';

      final result = adapter.parse(
        converter.convert(csv),
        explicitUnitSymbol: 'lb',
      );

      expect(result.sourceUnitSymbol, 'lb');
    });
  });

  group('Hevy CSV', () {
    const adapter = CsvImportAdapter(hevyColumnMapping);

    test('parses its own column names', () {
      const csv =
          'title,start_time,exercise_title,set_index,weight_kg,reps,set_type\n'
          'Push Day,2026-01-01 08:00:00,Bench Press,0,100,5,normal\n'
          'Push Day,2026-01-01 08:00:00,Bench Press,1,60,8,warmup\n';

      final result = adapter.parse(converter.convert(csv));

      expect(result.sourceUnitSymbol, 'kg');
      expect(result.sets, hasLength(2));
      expect(result.sets[1].isWarmup, isTrue);
    });
  });
}
