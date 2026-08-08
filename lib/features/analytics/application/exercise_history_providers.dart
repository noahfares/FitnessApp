import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../domain/analytics/exercise_history.dart';

/// Per-exercise history (`F-ANA-002`), keyed by exercise id
/// (`F-ANA-001` §4 — memoised, so switching between two exercise detail
/// screens doesn't re-run the other's query).
final exerciseHistoryProvider =
    StreamProvider.family<List<ExerciseHistorySession>, String>(
      (ref, exerciseId) =>
          ref.watch(setRepositoryProvider).watchExerciseHistory(exerciseId),
    );

/// The exercise itself, for the detail screen's header. A one-shot lookup
/// rather than a stream: the name and equipment shown here rarely change
/// mid-visit, and every other screen that needs a single exercise by id
/// (`ExerciseEditorScreen`) already reads it the same way.
final exerciseByIdProvider = FutureProvider.family<Exercise?, String>(
  (ref, exerciseId) =>
      ref.watch(exerciseRepositoryProvider).findById(exerciseId),
);
