import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../domain/history/workout_history.dart';
import '../../body/application/body_providers.dart';
import '../../body/presentation/log_bodyweight_sheet.dart';
import '../../history/application/history_providers.dart';
import '../../logging/application/active_workout_providers.dart';
import '../../logging/presentation/active_workout_screen.dart'
    show formatElapsed;
import '../../logging/presentation/start_workout_screen.dart';
import '../../routines/application/routine_providers.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../widgets/async_view.dart';
import '../widgets/empty_state.dart';
import '../widgets/weekly_insights_section.dart';
import '../../../core/l10n/l10n.dart';

/// The home tab (`F-NAV-004`): resume or start a workout first, then recent
/// activity, then everywhere else in the app.
///
/// Streaks and recent PRs depend on features that don't exist yet — they
/// arrive with those, not as placeholders here. Today's scheduled day
/// (`F-ROU-012`) landed in batch 3.5; weekly insight cards (`F-ANA-013`)
/// landed in Phase 4's closing pass.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recent = ref.watch(recentWorkoutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.l10n.shellSettings,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          const _ResumeOrStartCard(),
          const _TodaysScheduleCard(),
          const WeeklyInsightsSection(),
          const SizedBox(height: AppSpacing.md),
          const _BodyweightCard(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.shellRecentWorkouts,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          recent.view(
            (entries) => entries.isEmpty
                ? EmptyState(
                    icon: Icons.calendar_month_outlined,
                    title: context.l10n.shellNoWorkoutsYet,
                    message: context.l10n.shellYourFinishedSessionsWillShow,
                    actionLabel: context.l10n.shellStartAWorkout,
                    onAction: () => unawaited(showStartWorkoutSheet(context)),
                  )
                : Column(
                    children: [
                      for (final entry in entries)
                        _RecentWorkoutTile(entry: entry),
                    ],
                  ),
            errorTitle: context.l10n.shellRecentWorkoutsCouldNotBe,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.exercises),
                  icon: const Icon(Icons.fitness_center),
                  label: Text(context.l10n.historyExercises),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.history),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(context.l10n.catalogHistory),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The primary action (`F-NAV-004` §1) — deliberately the first thing on the
/// screen and sized to be unmissable, per the design brief's "primary actions
/// in the bottom half" reachability rule as far as a scrolling list allows.
class _ResumeOrStartCard extends ConsumerWidget {
  const _ResumeOrStartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final active = ref.watch(activeWorkoutProvider).value;

    if (active == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.shellReadyToTrain,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => unawaited(showStartWorkoutSheet(context)),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.loggingStartAWorkout),
              ),
            ],
          ),
        ),
      );
    }

    final elapsed = ref.watch(elapsedProvider);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: () => context.push(AppRoutes.activeWorkout),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      active.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      context.l10n.shellInProgressElapsed(
                        formatElapsed(elapsed),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Today: Push" — the day(s) scheduled for today (`F-ROU-012`), or nothing
/// at all when no day is scheduled or a workout is already in progress
/// (`_ResumeOrStartCard` already covers that case).
class _TodaysScheduleCard extends ConsumerWidget {
  const _TodaysScheduleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeWorkoutProvider).value;
    if (active != null) return const SizedBox.shrink();

    final scheduled = ref.watch(todaysScheduledDaysProvider).value ?? const [];
    if (scheduled.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        children: [
          for (final day in scheduled)
            Card(
              child: ListTile(
                leading: const Icon(Icons.today_outlined),
                title: Text(context.l10n.shellTodaysDay(day.dayName)),
                subtitle: Text(day.routineName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  AppRoutes.routineDay(day.routineId, day.dayId),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Quick bodyweight entry (`F-BOD-001` §4) — cheap enough to actually happen,
/// which is the whole point of capturing something unrecoverable.
class _BodyweightCard extends ConsumerWidget {
  const _BodyweightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final latest = ref.watch(latestBodyweightProvider).value;
    final formatter = ref.watch(quantityFormatterProvider);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.monitor_weight_outlined),
        title: Text(
          latest == null
              ? context.l10n.shellNoBodyweightLoggedYet
              : formatter.bodyweight(Mass.grams(latest.valueCanonical)),
          style: theme.textTheme.titleMedium,
        ),
        subtitle: latest == null
            ? Text(context.l10n.shellLogItToTrackAlongside)
            : Text(
                DateFormat.yMMMd().format(
                  DateTime.fromMillisecondsSinceEpoch(latest.measuredAt),
                ),
              ),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          tooltip: context.l10n.bodyLogBodyweight,
          onPressed: () => unawaited(showLogBodyweightSheet(context)),
        ),
        onTap: () => context.push(AppRoutes.body),
      ),
    );
  }
}

class _RecentWorkoutTile extends ConsumerWidget {
  const _RecentWorkoutTile({required this.entry});

  final WorkoutHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(quantityFormatterProvider);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(entry.name),
      subtitle: Text(
        '${entry.exerciseCount} '
        '${entry.exerciseCount == 1 ? 'exercise' : 'exercises'} · '
        '${formatter.volume(Mass.grams(entry.totalVolumeGrams))}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(AppRoutes.historyWorkout(entry.id)),
    );
  }
}
