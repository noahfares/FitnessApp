import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/tables/enums.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../history/application/history_providers.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../application/personal_record_providers.dart';
import 'active_workout_screen.dart' show formatElapsed;
import '../../../core/l10n/l10n.dart';

/// Shown on finishing a workout (`F-LOG-018`) — one of only two celebratory
/// moments in the app (docs/24-DESIGN-SYSTEM.md §motion).
class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({required this.workoutId, super.key});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(workoutSummaryStatsProvider(workoutId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.loggingWorkoutComplete)),
      body: stats.view(
        (stats) => _Summary(workoutId: workoutId, stats: stats),
        errorTitle: context.l10n.loggingThisSummaryCouldNotBe,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: Text(context.l10n.historyDone),
          ),
        ),
      ),
    );
  }
}

class _Summary extends ConsumerWidget {
  const _Summary({required this.workoutId, required this.stats});

  final String workoutId;
  final WorkoutSummaryStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(quantityFormatterProvider);
    final records =
        ref.watch(sessionRecordsProvider(workoutId)).value ?? const [];

    final volumeDelta = stats.previous == null
        ? null
        : stats.totalVolumeGrams - stats.previous!.totalVolumeGrams;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        Icon(
          Icons.celebration_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.loggingNiceWork,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _StatTile(
              label: context.l10n.historyDuration,
              value: formatElapsed(stats.duration),
            ),
            _StatTile(
              label: context.l10n.loggingVolume,
              value: formatter.volume(Mass.grams(stats.totalVolumeGrams)),
            ),
            _StatTile(
              label: context.l10n.loggingSets,
              value: '${stats.completedSetCount}',
            ),
            _StatTile(
              label: context.l10n.historyExercises,
              value: '${stats.exerciseCount}',
            ),
          ],
        ),
        if (records.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.loggingPersonalRecords,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final pr in records)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 18,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${pr.exerciseName ?? context.l10n.loggingUnknownExercise}'
                      ' — ${_describe(pr, formatter)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (stats.muscles.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.loggingMusclesWorked,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final muscle in stats.muscles)
                Chip(label: Text(muscle.label(context.l10n))),
            ],
          ),
        ],
        if (stats.previous != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.loggingComparedToLastTime,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            volumeDelta! >= 0
                ? '+${formatter.volume(Mass.grams(volumeDelta))} volume'
                : '${formatter.volume(Mass.grams(volumeDelta))} volume',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ],
    );
  }

  /// What kind of record [pr] is, in plain language
  /// (`docs/40-ANALYTICS-SPEC.md` §4).
  String _describe(SessionPr pr, QuantityFormatter formatter) {
    final record = pr.record;
    return switch (record.kind) {
      PrKind.maxWeight =>
        'heaviest set: ${formatter.setWeight(Mass.grams(record.value), showUnit: true)}',
      PrKind.bestE1rm =>
        'best estimated 1RM: ${formatter.e1rm(Mass.grams(record.value))}',
      PrKind.maxRepsAtWeight =>
        '${record.value} reps at '
            '${formatter.setWeight(Mass.grams(record.qualifier!), showUnit: true)}',
      PrKind.maxSessionVolume =>
        'most volume in a session: ${formatter.volume(Mass.grams(record.value))}',
    };
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 150,
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
