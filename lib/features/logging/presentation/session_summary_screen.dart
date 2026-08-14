import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/tables/enums.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../history/application/history_providers.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../application/personal_record_providers.dart';
import 'active_workout_screen.dart' show formatElapsed;

/// Shown on finishing a workout (`F-LOG-018`) — one of only two celebratory
/// moments in the app (docs/24-DESIGN-SYSTEM.md §motion).
class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({required this.workoutId, super.key});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(workoutSummaryStatsProvider(workoutId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionSummaryTitle)),
      body: stats.view(
        (stats) => _Summary(workoutId: workoutId, stats: stats),
        errorTitle: l10n.sessionSummaryReadError,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: Text(l10n.sessionSummaryDone),
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
    final l10n = AppLocalizations.of(context)!;
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
        Text(l10n.sessionSummaryNiceWork, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _StatTile(
              label: l10n.sessionSummaryDurationLabel,
              value: formatElapsed(stats.duration),
            ),
            _StatTile(
              label: l10n.sessionSummaryVolumeLabel,
              value: formatter.volume(Mass.grams(stats.totalVolumeGrams)),
            ),
            _StatTile(
              label: l10n.sessionSummarySetsLabel,
              value: '${stats.completedSetCount}',
            ),
            _StatTile(
              label: l10n.sessionSummaryExercisesLabel,
              value: '${stats.exerciseCount}',
            ),
          ],
        ),
        if (records.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.sessionSummaryPersonalRecordsTitle,
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
                      '${pr.exerciseName} — ${_describe(l10n, pr, formatter)}',
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
            l10n.sessionSummaryMusclesWorkedTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final muscle in stats.muscles)
                Chip(label: Text(muscle.label)),
            ],
          ),
        ],
        if (stats.previous != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.sessionSummaryComparedToLastTime,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.sessionSummaryVolumeChange(
              volumeDelta! >= 0
                  ? '+${formatter.volume(Mass.grams(volumeDelta))}'
                  : formatter.volume(Mass.grams(volumeDelta)),
            ),
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ],
    );
  }

  /// What kind of record [pr] is, in plain language
  /// (`docs/40-ANALYTICS-SPEC.md` §4).
  String _describe(
    AppLocalizations l10n,
    SessionPr pr,
    QuantityFormatter formatter,
  ) {
    final record = pr.record;
    return switch (record.kind) {
      PrKind.maxWeight => l10n.sessionSummaryPrHeaviestSet(
        formatter.setWeight(Mass.grams(record.value), showUnit: true),
      ),
      PrKind.bestE1rm => l10n.sessionSummaryPrBestE1rm(
        formatter.e1rm(Mass.grams(record.value)),
      ),
      PrKind.maxRepsAtWeight => l10n.sessionSummaryPrRepsAtWeight(
        record.value,
        formatter.setWeight(Mass.grams(record.qualifier!), showUnit: true),
      ),
      PrKind.maxSessionVolume => l10n.sessionSummaryPrSessionVolume(
        formatter.volume(Mass.grams(record.value)),
      ),
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
