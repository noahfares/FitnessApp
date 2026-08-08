import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/analytics/consistency.dart';
import '../../settings/application/week_start_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/calendar_heatmap.dart';
import '../application/analytics_clock_provider.dart';
import '../application/analytics_set_records_provider.dart';

/// Consistency (`F-ANA-006`) — a calendar heatmap of training days, current
/// and longest streak, and a rolling sessions-per-week average.
///
/// Streaks are motivating but must not shame (§5 rule 4): no red for a
/// missed week, no loss animation, no guilt copy anywhere on this screen.
class ConsistencyScreen extends ConsumerWidget {
  const ConsistencyScreen({super.key});

  static const int _weeklyTarget = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(analyticsSetRecordsProvider);
    final weekStart = ref.watch(weekStartProvider);
    final now = ref.watch(analyticsClockProvider)();

    return Scaffold(
      appBar: AppBar(title: const Text('Consistency')),
      body: records.view((records) {
        final days = trainingDays(records);
        final counts = weeklySessionCounts(
          days,
          weekStart: weekStart,
          now: now,
        );
        final stats = consistencyStats(counts, weeklyTarget: _weeklyTarget);
        final theme = Theme.of(context);

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            CalendarHeatmap(trainingDays: days, weekStart: weekStart, now: now),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _StatTile(
                  label: 'Current streak',
                  value: '${stats.currentStreak} wk',
                ),
                _StatTile(
                  label: 'Longest streak',
                  value: '${stats.longestStreak} wk',
                ),
                _StatTile(
                  label: 'Sessions / week',
                  value: stats.sessionsPerWeek.toStringAsFixed(1),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Target: $_weeklyTarget sessions a week. A streak is a run of '
              'complete weeks meeting it — the week in progress never breaks '
              'one, whatever it currently reads.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
