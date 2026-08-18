import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/tables/enums.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../history/application/history_providers.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/section_header.dart';
import '../application/personal_record_providers.dart';
import 'active_workout_screen.dart' show formatElapsed;
import '../../../core/l10n/l10n.dart';

/// Shown on finishing a workout (`F-LOG-018`) — one of only two celebratory
/// moments in the app (docs/24-DESIGN-SYSTEM.md §motion).
///
/// No app bar: a text `Close` action stands in for it, matching the Apple-
/// style pass's large-title/no-chrome convention on every other primary
/// screen. Type carries the celebration — the former `celebration_outlined`
/// glyph is gone; "Nice work." at 40/700 is the whole gesture.
class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({required this.workoutId, super.key});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final stats = ref.watch(workoutSummaryStatsProvider(workoutId));

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.loggingWorkoutComplete,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.15,
                      color: colors.labelSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.home),
                    child: Text(
                      context.l10n.shellClose,
                      style: TextStyle(fontSize: 17, color: colors.tint),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: stats.view(
                (stats) => _Summary(workoutId: workoutId, stats: stats),
                errorTitle: context.l10n.loggingThisSummaryCouldNotBe,
              ),
            ),
          ],
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
    final colors = context.appColors;
    final formatter = ref.watch(quantityFormatterProvider);
    final workout = ref.watch(workoutByIdProvider(workoutId)).value;
    final records =
        ref.watch(sessionRecordsProvider(workoutId)).value ?? const [];

    final volumeDelta = stats.previous == null
        ? null
        : stats.totalVolumeGrams - stats.previous!.totalVolumeGrams;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        Text(
          context.l10n.loggingNiceWork,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
            height: 1.05,
            color: colors.label,
          ),
        ),
        if (workout != null) ...[
          const SizedBox(height: 5),
          Text(
            '${workout.name} · '
            '${DateFormat('EEEE, d MMMM').format(DateTime.fromMillisecondsSinceEpoch(workout.startedAt))}',
            style: TextStyle(fontSize: 15, color: colors.labelSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        _StatGrid(
          tiles: [
            _StatTile(
              value: formatElapsed(stats.duration),
              label: context.l10n.historyDuration,
            ),
            _StatTile(
              value: formatter.volume(Mass.grams(stats.totalVolumeGrams)),
              label: context.l10n.loggingVolume,
            ),
            _StatTile(
              value: '${stats.completedSetCount}',
              label: context.l10n.loggingSets,
            ),
            _StatTile(
              value: '${stats.exerciseCount}',
              label: context.l10n.historyExercises,
            ),
          ],
        ),
        if (records.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(context.l10n.loggingPersonalRecords),
          const SizedBox(height: AppSpacing.sm),
          for (final pr in records)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PrCard(
                title: pr.exerciseName ?? context.l10n.loggingUnknownExercise,
                description: _describe(pr, formatter),
              ),
            ),
        ],
        if (stats.muscles.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(context.l10n.loggingMusclesWorked),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final muscle in stats.muscles)
                _MuscleChip(muscle.label(context.l10n)),
            ],
          ),
        ],
        if (stats.previous != null) ...[
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(context.l10n.loggingComparedToLastTime),
          const SizedBox(height: AppSpacing.sm),
          Text(
            volumeDelta! >= 0
                ? '+${formatter.volume(Mass.grams(volumeDelta))} volume'
                : '${formatter.volume(Mass.grams(volumeDelta))} volume',
            style: TextStyle(
              fontSize: 19,
              letterSpacing: -0.19,
              color: colors.label,
              fontFeatures: AppTheme.tabularFigures,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: Text(context.l10n.historyDone),
          ),
        ),
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

/// A 2×2 grid, gap 10 both axes — [tiles] is always exactly four.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.tiles});

  final List<_StatTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: tiles[0]),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: tiles[1]),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: tiles[2]),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: tiles[3]),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.48,
              color: colors.label,
              fontFeatures: AppTheme.tabularFigures,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.labelSecondary),
          ),
        ],
      ),
    );
  }
}

class _PrCard extends StatelessWidget {
  const _PrCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.prSurface,
        border: Border.all(color: colors.prBorder),
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.17,
              color: colors.label,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: colors.prBody,
              fontFeatures: AppTheme.tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  const _MuscleChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: TextStyle(fontSize: 14, color: colors.label)),
    );
  }
}
