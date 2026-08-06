import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../domain/history/workout_history.dart';
import '../../history/application/history_providers.dart';
import '../../logging/application/active_workout_providers.dart';
import '../../logging/presentation/active_workout_screen.dart'
    show formatElapsed;
import '../../logging/presentation/start_workout_screen.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../widgets/async_view.dart';
import '../widgets/empty_state.dart';

/// The home tab (`F-NAV-004`): resume or start a workout first, then recent
/// activity, then everywhere else in the app.
///
/// Today's scheduled day, streaks, recent PRs and insight cards all depend on
/// features that don't exist yet (`F-ROU-012`, PR detection, and the Phase 3
/// analytics providers) — they arrive with those, not as placeholders here.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recent = ref.watch(recentWorkoutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitnessApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          const _ResumeOrStartCard(),
          const SizedBox(height: AppSpacing.xl),
          Text('Recent workouts', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          recent.view(
            (entries) => entries.isEmpty
                ? EmptyState(
                    icon: Icons.calendar_month_outlined,
                    title: 'No workouts yet',
                    message: 'Your finished sessions will show up here.',
                    actionLabel: 'Start a workout',
                    onAction: () => unawaited(showStartWorkoutSheet(context)),
                  )
                : Column(
                    children: [
                      for (final entry in entries)
                        _RecentWorkoutTile(entry: entry),
                    ],
                  ),
            errorTitle: 'Recent workouts could not be read',
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.exercises),
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Exercises'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.history),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('History'),
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
              Text('Ready to train?', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => unawaited(showStartWorkoutSheet(context)),
                icon: const Icon(Icons.add),
                label: const Text('Start a workout'),
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
                      'In progress · ${formatElapsed(elapsed)}',
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
