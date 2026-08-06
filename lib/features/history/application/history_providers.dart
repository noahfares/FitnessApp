import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../domain/history/workout_history.dart';

/// The search box on the history list (`F-LOG-011` §4). Ephemeral UI state,
/// not persisted — clearing it on leaving the screen is the expected
/// behaviour.
final historySearchProvider = NotifierProvider<HistorySearchNotifier, String>(
  HistorySearchNotifier.new,
);

class HistorySearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

/// How many rows [historyProvider] asks for. Raised as the list is scrolled
/// (`F-LOG-011` §3); a fresh query with a bigger limit rather than manual
/// pagination, since the underlying table is small enough for that to stay
/// cheap through Phase 1.
final historyPageSizeProvider = NotifierProvider<HistoryPageSizeNotifier, int>(
  HistoryPageSizeNotifier.new,
);

class HistoryPageSizeNotifier extends Notifier<int> {
  static const int pageSize = 50;

  @override
  int build() => pageSize;

  void loadMore() => state += pageSize;
}

/// Finished sessions, newest first, filtered by [historySearchProvider] and
/// bounded by [historyPageSizeProvider].
final historyProvider = StreamProvider<List<WorkoutHistoryEntry>>((ref) {
  final query = ref.watch(historySearchProvider);
  final limit = ref.watch(historyPageSizeProvider);
  return ref
      .watch(workoutRepositoryProvider)
      .watchHistory(query: query, limit: limit);
});

/// [historyProvider]'s entries split into calendar months for the sticky
/// section headers (`F-LOG-011` §2).
final historyByMonthProvider = Provider<List<MonthGroup>>((ref) {
  final entries = ref.watch(historyProvider).value ?? const [];
  return groupByMonth(entries);
});

/// One workout, active or finished (history detail and edit screens).
final workoutByIdProvider = StreamProvider.family<Workout?, String>(
  (ref, workoutId) => ref.watch(workoutRepositoryProvider).watchById(workoutId),
);

/// Totals for the finish summary (`F-LOG-018`).
final workoutSummaryStatsProvider =
    FutureProvider.family<WorkoutSummaryStats, String>(
      (ref, workoutId) =>
          ref.watch(workoutRepositoryProvider).summaryStats(workoutId),
    );
