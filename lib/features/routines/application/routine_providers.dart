import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/routine_repository.dart';

/// The routine list (`F-ROU-001`). Archived routines are excluded — the same
/// organisational-hide rule as archived exercises.
final routinesProvider = StreamProvider<List<Routine>>(
  (ref) => ref.watch(routineRepositoryProvider).watchAll(),
);

/// One routine's days, ordered (`F-ROU-002`).
final routineDaysProvider = StreamProvider.family<List<RoutineDay>, String>(
  (ref, routineId) =>
      ref.watch(routineRepositoryProvider).watchDays(routineId),
);

/// One day's exercises with their targets (`F-ROU-003`).
final routineDayExercisesProvider =
    StreamProvider.family<List<RoutineExerciseDetail>, String>(
      (ref, dayId) =>
          ref.watch(routineRepositoryProvider).watchExercises(dayId),
    );
