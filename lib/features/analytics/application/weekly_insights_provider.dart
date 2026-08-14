import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/analytics/weekly_insights.dart';
import '../../settings/application/week_start_provider.dart';
import 'analytics_clock_provider.dart';
import 'analytics_set_records_provider.dart';

/// The dashboard's weekly insight cards (`F-ANA-013`) — ranked, capped, and
/// empty until there's enough history to say anything without inventing it
/// (§14 rule 1).
final weeklyInsightsProvider = Provider<AsyncValue<List<WeeklyInsight>>>((ref) {
  final records = ref.watch(analyticsSetRecordsProvider);
  final weekStart = ref.watch(weekStartProvider);
  final now = ref.watch(analyticsClockProvider);
  return records.whenData(
    (records) =>
        generateWeeklyInsights(records, weekStart: weekStart, now: now()),
  );
});
