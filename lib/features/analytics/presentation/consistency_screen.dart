import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/analytics/consistency.dart';
import '../../../domain/analytics/schedule_adherence.dart';
import '../../routines/application/routine_providers.dart';
import '../../settings/application/week_start_provider.dart';
import '../../settings/application/weekly_target_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/calendar_heatmap.dart';
import '../application/analytics_clock_provider.dart';
import '../application/analytics_set_records_provider.dart';
import '../../../core/l10n/l10n.dart';

/// Consistency (`F-ANA-006`) — a calendar heatmap of training days, current
/// and longest streak, and a rolling sessions-per-week average.
///
/// Streaks are motivating but must not shame (§5 rule 4): no red for a
/// missed week, no loss animation, no guilt copy anywhere on this screen.
class ConsistencyScreen extends ConsumerWidget {
  const ConsistencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(analyticsSetRecordsProvider);
    final weekStart = ref.watch(weekStartProvider);
    final now = ref.watch(analyticsClockProvider)();
    final weeklyTarget = ref.watch(weeklyTargetProvider);
    final scheduled = ref.watch(scheduledWeekdaysProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.analyticsConsistency)),
      body: records.view((records) {
        final days = trainingDays(records);
        final counts = weeklySessionCounts(
          days,
          weekStart: weekStart,
          now: now,
        );
        final stats = consistencyStats(counts, weeklyTarget: weeklyTarget);
        // Four weeks: the same trailing window the sessions-per-week average
        // uses, so the two figures on this screen describe the same period.
        final adherence = scheduleAdherence(
          scheduledWeekdays: scheduled,
          trainingDays: days,
          from: now.subtract(const Duration(days: 27)),
          to: now,
        );
        final theme = Theme.of(context);

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            CalendarHeatmap(trainingDays: days, weekStart: weekStart, now: now),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _StatTile(
                  label: context.l10n.analyticsCurrentStreak,
                  value: '${stats.currentStreak} wk',
                ),
                _StatTile(
                  label: context.l10n.analyticsLongestStreak,
                  value: '${stats.longestStreak} wk',
                ),
                _StatTile(
                  label: context.l10n.analyticsSessionsWeek,
                  value: stats.sessionsPerWeek.toStringAsFixed(1),
                ),
              ],
            ),
            if (adherence.ratio case final ratio?) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.analyticsScheduleAdherence,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.analyticsScheduleAdherenceValue(
                  (ratio * 100).round(),
                  adherence.trained,
                  adherence.scheduled,
                ),
                style: theme.textTheme.bodyMedium,
              ),
              if (adherence.unscheduledSessions > 0)
                Text(
                  context.l10n.analyticsUnscheduledSessions(
                    adherence.unscheduledSessions,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.analyticsWeeklyTarget,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                for (final target in const [2, 3, 4, 5, 6])
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text('$target'),
                      selected: target == weeklyTarget,
                      onSelected: (_) => unawaited(
                        ref.read(weeklyTargetProvider.notifier).set(target),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.analyticsStreakExplainer(weeklyTarget),
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
