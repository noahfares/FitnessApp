import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/app_routes.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/workout_repository.dart';

/// The in-progress session, or null (`F-LOG-001`, `F-LOG-007`).
///
/// **One provider, watched by every part of the logger**
/// (docs/23-NAVIGATION.md §state-management). Duplicating session state is how
/// two parts of a screen end up disagreeing about whether a workout is running.
final activeWorkoutProvider = StreamProvider<Workout?>(
  (ref) => ref.watch(workoutRepositoryProvider).watchActive(),
);

/// The exercises in a session, with set counts.
final sessionExercisesProvider =
    StreamProvider.family<List<SessionExercise>, String>(
      (ref, workoutId) =>
          ref.watch(workoutRepositoryProvider).watchExercises(workoutId),
    );

/// Wall-clock ticks, once a second, only while something is watching.
///
/// A provider rather than a `Timer` in widget state for one practical reason:
/// a periodic timer means `pumpAndSettle` never settles, so every widget test
/// touching the active workout would have to hand-roll its pumping. Overriding
/// this with a fixed value in tests keeps the screen testable without making
/// the elapsed clock fake in production.
final clockTickProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});

/// How long the session has been running.
///
/// Derived from `started_at` rather than counted up, so it survives the app
/// being killed and reopened with the right value (`F-LOG-007` §3).
final elapsedProvider = Provider<Duration>((ref) {
  final workout = ref.watch(activeWorkoutProvider).value;
  if (workout == null) return Duration.zero;

  final now = ref.watch(clockTickProvider).value ?? DateTime.now();
  final elapsed = now.millisecondsSinceEpoch - workout.startedAt;
  return Duration(milliseconds: elapsed < 0 ? 0 : elapsed);
});

/// A session left open overnight is almost always one someone forgot to
/// finish, not one still running (`F-LOG-001` §edge-cases).
///
/// It resumes anyway — `F-LOG-007` §4 is explicit that there is no
/// "restore session?" prompt, because prompting invites the wrong answer under
/// stress. The screen surfaces it instead, where finishing or discarding is one
/// tap and neither is the default.
const Duration staleSessionThreshold = Duration(hours: 12);

final activeWorkoutIsStaleProvider = Provider<bool>((ref) {
  final workout = ref.watch(activeWorkoutProvider).value;
  if (workout == null) return false;
  return ref.watch(elapsedProvider) > staleSessionThreshold;
});

/// Where to open, given whether a session was in progress (`F-LOG-007` §2).
///
/// It just resumes. There is deliberately no "restore session?" prompt:
/// prompting invites the wrong answer under stress, and the right answer is
/// never "throw it away".
String startupLocationFor(Workout? active) =>
    active == null ? AppRoutes.home : AppRoutes.activeWorkout;

/// Where the app opens.
///
/// Overridden in `main()` once the database has been asked whether a session is
/// in progress. Resolved before the first frame rather than redirected
/// afterwards, so recovery is not a visible flash of the dashboard. Defaults to
/// Home, which is where an app with no session belongs.
final startupLocationProvider = Provider<String>((ref) => AppRoutes.home);
