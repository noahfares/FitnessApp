import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart';
import '../../../data/platform/health_connect_service.dart';
import '../../../domain/analytics/bodyweight_trend.dart';
import '../../settings/application/health_connect_settings_provider.dart';

/// Every bodyweight entry, most recent first (`F-BOD-001`).
final bodyweightHistoryProvider = StreamProvider<List<BodyMeasurement>>(
  (ref) =>
      ref.watch(bodyMeasurementRepositoryProvider).watchBodyweightHistory(),
);

/// Pulls in whatever Health Connect has that this app does not yet
/// (`F-HLT-002`) — watched once from `BodyWeightScreen.build`, which is
/// this app's own trigger for "automatically" in that feature's spec; there
/// is no separate manual "sync now" button. A no-op, not an error, when the
/// toggle is off — `bodyweightHistoryProvider`'s own stream is what
/// actually reflects any newly-imported rows, so nothing here needs to
/// return or render the count.
final healthConnectBodyweightSyncProvider = FutureProvider<void>((ref) async {
  if (!ref.watch(healthConnectEnabledProvider)) return;
  final healthConnect = ref.watch(healthConnectServiceProvider);
  await ref
      .read(bodyMeasurementRepositoryProvider)
      .syncBodyweightFromHealthConnect(healthConnect);
});

/// The most recent entry, for the dashboard's quick-entry card.
final latestBodyweightProvider = StreamProvider<BodyMeasurement?>(
  (ref) => ref.watch(bodyMeasurementRepositoryProvider).watchLatestBodyweight(),
);

/// Every entry of a tracked measurement type, most recent first
/// (`F-BOD-002`).
final measurementHistoryProvider =
    StreamProvider.family<List<BodyMeasurement>, MeasurementType>(
      (ref, type) =>
          ref.watch(bodyMeasurementRepositoryProvider).watchHistory(type),
    );

/// The most recent entry of a tracked measurement type, for its summary
/// tile (`F-BOD-002`).
final latestMeasurementProvider =
    StreamProvider.family<BodyMeasurement?, MeasurementType>(
      (ref, type) =>
          ref.watch(bodyMeasurementRepositoryProvider).watchLatest(type),
    );

/// The bodyweight trend (raw + EMA), oldest first, and its weekly rate of
/// change (`F-BOD-003`).
final bodyweightTrendProvider = Provider<AsyncValue<BodyweightTrend>>((ref) {
  final history = ref.watch(bodyweightHistoryProvider);
  return history.whenData((entries) {
    // The repository watches newest-first for the log screen; the trend
    // reads oldest-first, since the EMA advances forward through time.
    final chronological = entries.reversed.toList();
    final trend = bodyweightTrendEma([
      for (final e in chronological)
        (measuredAtEpochMs: e.measuredAt, grams: e.valueCanonical),
    ]);
    return BodyweightTrend(
      points: trend,
      weeklyRateGrams: weeklyRateOfChangeGrams(trend),
    );
  });
});

class BodyweightTrend {
  const BodyweightTrend({required this.points, required this.weeklyRateGrams});

  final List<BodyweightTrendPoint> points;
  final double? weeklyRateGrams;
}
