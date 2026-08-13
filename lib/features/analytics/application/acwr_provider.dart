import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/analytics/acwr.dart';
import '../../../domain/analytics/weekly_volume.dart';
import 'analytics_clock_provider.dart';
import 'analytics_set_records_provider.dart';

/// The app-wide acute:chronic workload ratio (`F-ANA-010`) — one number
/// covering every exercise, unlike the per-exercise stall detection it pairs
/// with for a deload suggestion (`F-PRG-011`). Null (inside the [AsyncValue])
/// when there isn't 28 days of history yet — not shown, not a guess.
final acwrProvider = Provider<AsyncValue<AcwrResult?>>((ref) {
  final records = ref.watch(analyticsSetRecordsProvider);
  final now = ref.watch(analyticsClockProvider);
  return records.whenData(
    (records) => computeAcwr(dailyVolume(records), asOf: now()),
  );
});
