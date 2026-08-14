import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/database_provider.dart';
import '../../../domain/analytics/duration_compliance.dart';
import '../../settings/application/rest_timer_settings_provider.dart';

/// Session duration trend (`F-ANA-012`) — every finished session, oldest to
/// newest. `500` is generous enough to cover years of real use without an
/// unbounded query.
final sessionDurationTrendProvider = StreamProvider<List<SessionDurationPoint>>(
  (ref) {
    final workouts = ref.watch(workoutRepositoryProvider);
    return workouts
        .watchHistory(limit: 500)
        .map(
          (entries) => sessionDurationTrend([
            for (final e in entries)
              (
                date: e.localDate,
                startedAtMs: e.startedAt,
                endedAtMs: e.endedAt,
              ),
          ]),
        );
  },
);

/// Rest actually taken vs. the exercise's currently resolved rest
/// (`F-ANA-012`) — see `SetRepository.watchRestCompliance`'s own doc comment
/// for why "prescribed" is an approximation, not a historical snapshot.
final restComplianceProvider = StreamProvider<double?>((ref) {
  final sets = ref.watch(setRepositoryProvider);
  final globalDefault = ref.watch(restTimerSettingsProvider).defaultSeconds;
  return sets
      .watchRestCompliance(globalDefaultSeconds: globalDefault)
      .map(averageRestComplianceRatio);
});
