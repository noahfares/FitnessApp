import 'package:intl/intl.dart';

import 'imported_set.dart';

/// A CSV export's header didn't contain every column this adapter needs, or
/// contained none of the header spellings any known version has used —
/// `F-DAT-005`'s own "Open questions": *"fail loudly on an unrecognised
/// [layout]"* rather than guess at a column.
class UnrecognisedCsvFormatException implements Exception {
  const UnrecognisedCsvFormatException(this.formatName, this.missingFields);

  final String formatName;
  final List<String> missingFields;

  @override
  String toString() =>
      "$formatName export not recognised — missing ${missingFields.join(', ')}";
}

/// The source file's weight unit couldn't be established with certainty
/// (spec §3: *"never guess — a silently mis-imported history is worse than
/// a failed import"*). Carries the parsed rows so a caller can re-invoke
/// [CsvImportAdapter.parse] with an explicit unit once the user has picked
/// one, without re-reading the file.
class AmbiguousUnitException implements Exception {
  const AmbiguousUnitException();
}

/// One semantic field's possible header spellings across format versions —
/// the mechanism `F-DAT-005`'s own spec asks for ("support detection of
/// multiple layouts"). Matched case-insensitively, ignoring any parenthetical
/// suffix (`"Weight (kg)"` matches a `"weight"` candidate).
class FieldCandidates {
  const FieldCandidates(this.names);
  final List<String> names;
}

/// Declarative shape of one export format — the "mapping file" `F-DAT-006`'s
/// spec asks for, so Hevy is a second `ColumnMapping` rather than a second
/// importer.
class ColumnMapping {
  const ColumnMapping({
    required this.formatName,
    required this.date,
    required this.workoutName,
    required this.exerciseName,
    required this.setOrder,
    required this.weight,
    required this.reps,
    this.weightUnit = const FieldCandidates([]),
    this.distance = const FieldCandidates([]),
    this.duration = const FieldCandidates([]),
    this.rpe = const FieldCandidates([]),
    this.notes = const FieldCandidates([]),
    this.setType = const FieldCandidates([]),
    this.dateFormats = const [],
  });

  final String formatName;
  final FieldCandidates date;
  final FieldCandidates workoutName;
  final FieldCandidates exerciseName;
  final FieldCandidates setOrder;
  final FieldCandidates weight;
  final FieldCandidates reps;
  final FieldCandidates weightUnit;
  final FieldCandidates distance;
  final FieldCandidates duration;
  final FieldCandidates rpe;
  final FieldCandidates notes;
  final FieldCandidates setType;

  /// Tried in order; the first pattern that parses the first data row wins.
  final List<String> dateFormats;
}

class ParsedImport {
  const ParsedImport({required this.sets, required this.sourceUnitSymbol});

  final List<ImportedSet> sets;

  /// `"kg"` or `"lb"`/`"lbs"`, whichever the file itself named — the caller
  /// converts to canonical grams. Never inferred from the app's own display
  /// preference (spec §3).
  final String sourceUnitSymbol;
}

/// The shared pipeline `F-DAT-006`'s spec asks for: one engine, driven by a
/// [ColumnMapping] per format, so a third source is a new mapping rather
/// than a new importer.
class CsvImportAdapter {
  const CsvImportAdapter(this.mapping);

  final ColumnMapping mapping;

  /// [rows] is the decoded CSV table, header row first (as `csv` package's
  /// `CsvToListConverter` produces it). [explicitUnitSymbol] overrides
  /// unit detection — set when the caller is re-parsing after the user
  /// answered an [AmbiguousUnitException] prompt.
  ///
  /// The caller owns decoding, not this adapter — and must normalise line
  /// endings first (`text.replaceAll('\r\n', '\n')`) and pass
  /// `CsvToListConverter(eol: '\n')` explicitly. The converter's own
  /// eol auto-detection does not reliably split rows on a bare `\n` in this
  /// codebase's toolchain, confirmed directly rather than assumed.
  ParsedImport parse(List<List<dynamic>> rows, {String? explicitUnitSymbol}) {
    if (rows.isEmpty) {
      throw UnrecognisedCsvFormatException(mapping.formatName, [
        '(empty file)',
      ]);
    }
    final header = [for (final h in rows.first) h.toString()];

    final columns = <String, int>{};
    final missing = <String>[];
    void resolve(String field, FieldCandidates candidates) {
      final index = _findColumn(header, candidates.names);
      if (index == null) {
        missing.add(field);
      } else {
        columns[field] = index;
      }
    }

    resolve('date', mapping.date);
    resolve('workout name', mapping.workoutName);
    resolve('exercise name', mapping.exerciseName);
    resolve('set order', mapping.setOrder);
    resolve('weight', mapping.weight);
    resolve('reps', mapping.reps);
    if (missing.isNotEmpty) {
      throw UnrecognisedCsvFormatException(mapping.formatName, missing);
    }

    final distanceCol = _findColumn(header, mapping.distance.names);
    final durationCol = _findColumn(header, mapping.duration.names);
    final rpeCol = _findColumn(header, mapping.rpe.names);
    final notesCol = _findColumn(header, mapping.notes.names);
    final setTypeCol = _findColumn(header, mapping.setType.names);
    final weightUnitCol = _findColumn(header, mapping.weightUnit.names);

    final unitSymbol =
        explicitUnitSymbol ??
        _detectUnit(header[columns['weight']!]) ??
        (weightUnitCol != null && rows.length > 1
            ? _normaliseUnit(rows[1][weightUnitCol].toString())
            : null);
    if (unitSymbol == null) {
      throw const AmbiguousUnitException();
    }

    final dateFormats = [
      for (final pattern in mapping.dateFormats) DateFormat(pattern),
    ];

    final sets = <ImportedSet>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= columns['exercise name']!) continue;
      final dateText = row[columns['date']!].toString();
      DateTime? startedAt;
      for (final format in dateFormats) {
        try {
          startedAt = format.parseStrict(dateText);
          break;
        } on FormatException {
          continue;
        }
      }
      startedAt ??= DateTime.tryParse(dateText);
      if (startedAt == null) continue;

      // Strong marks a warm-up set inside the set-order cell itself
      // ("W1", "W2"), not a separate column — check both that and any
      // dedicated set-type column a format does have (Hevy's `set_type`).
      final rawSetOrder = row[columns['set order']!].toString().trim();
      final isWarmupFromOrder = RegExp(r'^[wW]').hasMatch(rawSetOrder);
      final isWarmupFromType =
          setTypeCol != null &&
          row[setTypeCol].toString().toLowerCase().contains('warm');

      sets.add(
        ImportedSet(
          workoutStartedAt: startedAt,
          workoutName: row[columns['workout name']!].toString(),
          exerciseName: row[columns['exercise name']!].toString().trim(),
          setOrder:
              int.tryParse(rawSetOrder.replaceAll(RegExp(r'[^0-9]'), '')) ?? i,
          weight: double.tryParse(row[columns['weight']!].toString()),
          reps: int.tryParse(row[columns['reps']!].toString()),
          distance: distanceCol == null
              ? null
              : double.tryParse(row[distanceCol].toString()),
          durationSeconds: durationCol == null
              ? null
              : int.tryParse(row[durationCol].toString()),
          rpe: rpeCol == null ? null : double.tryParse(row[rpeCol].toString()),
          isWarmup: isWarmupFromOrder || isWarmupFromType,
          notes: notesCol == null || row[notesCol].toString().isEmpty
              ? null
              : row[notesCol].toString(),
        ),
      );
    }

    return ParsedImport(sets: sets, sourceUnitSymbol: unitSymbol);
  }

  int? _findColumn(List<String> header, List<String> candidates) {
    for (var i = 0; i < header.length; i++) {
      final normalised = header[i]
          .trim()
          .toLowerCase()
          // Drop a parenthetical unit ("Weight (kg)") and an underscore-
          // suffixed one ("weight_kg") alike — both name a column and a
          // unit in one string, and only the column name matters here.
          .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
          .replaceAll(RegExp(r'_(kg|kgs|lb|lbs|km|mi)$'), '')
          .replaceAll('_', ' ')
          .trim();
      if (candidates.contains(normalised)) return i;
    }
    return null;
  }

  /// A unit named directly in the header — `"Weight (kg)"`,
  /// `"weight_kg"` — is certain; nothing else is (spec §3).
  String? _detectUnit(String weightHeader) {
    final match = RegExp(
      r'\((kg|kgs|lb|lbs)\)|_(kg|lb)\b',
      caseSensitive: false,
    ).firstMatch(weightHeader);
    if (match == null) return null;
    return _normaliseUnit(match.group(1) ?? match.group(2) ?? '');
  }

  String _normaliseUnit(String raw) {
    final lower = raw.trim().toLowerCase();
    return lower.startsWith('kg') ? 'kg' : 'lb';
  }
}

const strongColumnMapping = ColumnMapping(
  formatName: 'Strong',
  date: FieldCandidates(['date']),
  workoutName: FieldCandidates(['workout name']),
  exerciseName: FieldCandidates(['exercise name']),
  setOrder: FieldCandidates(['set order']),
  weight: FieldCandidates(['weight']),
  reps: FieldCandidates(['reps']),
  weightUnit: FieldCandidates(['weight unit', 'unit']),
  distance: FieldCandidates(['distance']),
  duration: FieldCandidates(['seconds', 'duration']),
  rpe: FieldCandidates(['rpe']),
  notes: FieldCandidates(['notes']),
  dateFormats: [
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd HH:mm',
    'M/d/yyyy, h:mm a',
    'M/d/yyyy HH:mm',
  ],
);

const hevyColumnMapping = ColumnMapping(
  formatName: 'Hevy',
  date: FieldCandidates(['start time']),
  workoutName: FieldCandidates(['title', 'workout name']),
  exerciseName: FieldCandidates(['exercise title', 'exercise name']),
  setOrder: FieldCandidates(['set order', 'set index']),
  weight: FieldCandidates(['weight']),
  reps: FieldCandidates(['reps']),
  distance: FieldCandidates(['distance']),
  duration: FieldCandidates(['duration', 'seconds']),
  rpe: FieldCandidates(['rpe']),
  notes: FieldCandidates(['exercise notes', 'notes']),
  setType: FieldCandidates(['set type']),
  dateFormats: ['yyyy-MM-dd HH:mm:ss', 'd MMM yyyy, HH:mm'],
);
