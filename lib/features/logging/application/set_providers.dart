import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/set_repository.dart';
import '../../../domain/logging/ghost_matching.dart';

/// The sets of one exercise within the session, in display order
/// (`F-LOG-003`).
final setsProvider = StreamProvider.family<List<WorkoutSet>, String>(
  (ref, workoutExerciseId) =>
      ref.watch(setRepositoryProvider).watchSets(workoutExerciseId),
);

/// Last time's values for an exercise (`F-LOG-004`), keyed by **exercise** id
/// rather than by the row in this session — the whole point is that it comes
/// from a different session.
final ghostSetsProvider = StreamProvider.family<List<GhostSet>, String>(
  (ref, exerciseId) =>
      ref.watch(setRepositoryProvider).watchGhostSetsFor(exerciseId),
);

/// This exercise's rows paired with last session's, one entry per current row
/// (`F-LOG-004` §1, §5, §6).
///
/// Composed here rather than in the widget so the pairing is computed once per
/// data change instead of once per row build, and so the rule itself stays in
/// pure domain code (`matchGhostIndices`).
final ghostsForExerciseProvider = Provider.family<List<GhostSet?>, GhostQuery>((
  ref,
  query,
) {
  final sets = ref.watch(setsProvider(query.workoutExerciseId)).value;
  if (sets == null || sets.isEmpty) return const [];

  final previous = ref.watch(ghostSetsProvider(query.exerciseId)).value;
  if (previous == null || previous.isEmpty) {
    return List<GhostSet?>.filled(sets.length, null);
  }

  final indices = matchGhostIndices(
    currentTypes: [for (final set in sets) set.setType.name],
    previousTypes: [for (final ghost in previous) ghost.setType],
  );
  return [for (final index in indices) index == null ? null : previous[index]];
});

/// The two ids a ghost lookup needs. A record would do, but a named type keeps
/// the family key readable in devtools and in error messages.
class GhostQuery {
  const GhostQuery({required this.workoutExerciseId, required this.exerciseId});

  final String workoutExerciseId;
  final String exerciseId;

  @override
  bool operator ==(Object other) =>
      other is GhostQuery &&
      other.workoutExerciseId == workoutExerciseId &&
      other.exerciseId == exerciseId;

  @override
  int get hashCode => Object.hash(workoutExerciseId, exerciseId);
}
