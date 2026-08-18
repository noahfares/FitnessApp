import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';

/// The set ids currently holding a cached PR for an exercise — drives the
/// inline badge on the set row (`F-LOG-013` §2). Streamed so a demotion, from
/// a later rebuild, removes the badge without the row needing to be told.
final recordSetIdsProvider = StreamProvider.family<Set<String>, String>(
  (ref, exerciseId) =>
      ref.watch(personalRecordRepositoryProvider).watchRecordSetIds(exerciseId),
);

/// One record achieved in a session, with the exercise name resolved for
/// display — what the finish summary lists (`F-LOG-018` §3).
class SessionPr {
  const SessionPr({required this.record, required this.exerciseName});

  final PersonalRecord record;

  /// Null when the exercise has since been deleted — the screen decides what
  /// that reads as, since only it can localise (`F-I18N-001`).
  final String? exerciseName;
}

/// The records achieved in [workoutId], for the finish summary.
///
/// Read-only: it does not evaluate anything itself. `maxSessionVolume` only
/// appears here because `active_workout_screen.dart`'s finish action already
/// called `evaluateSessionVolume` for this workout before navigating here;
/// the other three kinds are already in the cache from each set's own live
/// completion (`F-LOG-013` §1).
final sessionRecordsProvider = FutureProvider.family<List<SessionPr>, String>((
  ref,
  workoutId,
) async {
  final records = await ref
      .watch(personalRecordRepositoryProvider)
      .recordsForWorkout(workoutId);
  if (records.isEmpty) return const [];

  final exercises = ref.watch(exerciseRepositoryProvider);
  return [
    for (final record in records)
      SessionPr(
        record: record,
        // Null rather than a placeholder string: this is the application
        // layer, with no context to localise against (`F-I18N-001`). The
        // screen showing it decides what a missing name reads as.
        exerciseName: (await exercises.findById(record.exerciseId))?.name,
      ),
  ];
});
