/// The two operations that actually move data (`F-HLT-001`, `F-HLT-002`).
///
/// Kept out of the screens so that "never blocks finishing a workout" is a
/// property of one function rather than a promise each call site has to keep:
/// both of these swallow every failure and report what happened as a value.
library;

import '../../../data/platform/health_service.dart';
import '../../../data/repositories/body_measurement_repository.dart';

/// Writes a finished session out, if the user asked for that.
///
/// Returns false for every uninteresting reason — switched off, no permission,
/// no health store, plugin threw — because the caller's response to all of
/// them is identical: carry on. The local record was always the authoritative
/// one (`F-HLT-001` §3).
Future<bool> writeWorkoutToHealth(
  HealthService service, {
  required bool enabled,
  required DateTime start,
  required DateTime end,
  String? title,
}) async {
  if (!enabled) return false;
  if (!await service.hasPermissions(read: false)) return false;
  return service.writeWorkout(start: start, end: end, title: title);
}

/// What [importBodyweightFromHealth] did, so the screen can say so plainly.
class BodyweightImportResult {
  const BodyweightImportResult({required this.imported, required this.skipped});

  final int imported;

  /// Days that already had a local entry. **Local wins** — this app's own log
  /// is what the user typed, and a scale's reading should never quietly
  /// overwrite it (`F-HLT-002`'s conflict rule).
  final int skipped;
}

Future<BodyweightImportResult> importBodyweightFromHealth(
  HealthService service,
  BodyMeasurementRepository repo, {
  required DateTime from,
  required DateTime to,
}) async {
  if (!await service.hasPermissions(read: true)) {
    return const BodyweightImportResult(imported: 0, skipped: 0);
  }

  final entries = await service.readBodyweight(from: from, to: to);
  if (entries.isEmpty) {
    return const BodyweightImportResult(imported: 0, skipped: 0);
  }

  final existing = await repo.watchBodyweightHistory().first;
  final localDays = {
    for (final entry in existing)
      _dayKey(DateTime.fromMillisecondsSinceEpoch(entry.measuredAt)),
  };

  var imported = 0;
  var skipped = 0;
  final seen = <String>{};
  for (final entry in entries) {
    final day = _dayKey(entry.measuredAt);
    if (localDays.contains(day) || !seen.add(day)) {
      skipped++;
      continue;
    }
    await repo.logBodyweight(grams: entry.grams, measuredAt: entry.measuredAt);
    imported++;
  }
  return BodyweightImportResult(imported: imported, skipped: skipped);
}

String _dayKey(DateTime moment) =>
    '${moment.year}-${moment.month}-${moment.day}';
