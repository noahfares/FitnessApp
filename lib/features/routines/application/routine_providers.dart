import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/routine_repository.dart';
import '../../analytics/application/analytics_clock_provider.dart';

/// The routine list (`F-ROU-001`). Archived routines are excluded — the same
/// organisational-hide rule as archived exercises.
final routinesProvider = StreamProvider<List<Routine>>(
  (ref) => ref.watch(routineRepositoryProvider).watchAll(),
);

/// Archived routines only — for the "restore" view (`F-ROU-009`).
final archivedRoutinesProvider = StreamProvider<List<Routine>>((ref) {
  return ref
      .watch(routineRepositoryProvider)
      .watchAll(includeArchived: true)
      .map(
        (rows) => [
          for (final r in rows)
            if (r.archivedAt != null) r,
        ],
      );
});

/// Folders, flat, one level deep (`F-ROU-007`).
final routineFoldersProvider = StreamProvider<List<RoutineFolder>>(
  (ref) => ref.watch(routineRepositoryProvider).watchFolders(),
);

/// Whether the routine list is showing archived routines instead of active
/// ones (`F-ROU-009`). Ephemeral UI state, same reasoning as
/// `catalogFilterProvider` — not worth persisting across restarts.
final routineListShowArchivedProvider =
    NotifierProvider<RoutineListShowArchivedNotifier, bool>(
      RoutineListShowArchivedNotifier.new,
    );

class RoutineListShowArchivedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

/// One routine's days, ordered (`F-ROU-002`).
final routineDaysProvider = StreamProvider.family<List<RoutineDay>, String>(
  (ref, routineId) => ref.watch(routineRepositoryProvider).watchDays(routineId),
);

/// One day's exercises with their targets (`F-ROU-003`).
final routineDayExercisesProvider =
    StreamProvider.family<List<RoutineExerciseDetail>, String>(
      (ref, dayId) =>
          ref.watch(routineRepositoryProvider).watchExercises(dayId),
    );

/// Every day scheduled for today (`F-ROU-012`) — the dashboard's
/// "today: Push" card.
final todaysScheduledDaysProvider = StreamProvider<List<ScheduledDay>>((ref) {
  final now = ref.watch(analyticsClockProvider)();
  return ref.watch(routineRepositoryProvider).watchDaysForWeekday(now.weekday);
});
