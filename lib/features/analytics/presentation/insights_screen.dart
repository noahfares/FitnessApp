import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/analytics/analytics_set_record.dart';
import '../../../domain/analytics/date_range.dart';
import '../../../domain/analytics/sets_per_muscle.dart';
import '../../../domain/analytics/weekly_volume.dart';
import '../../catalog/presentation/exercise_labels.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../settings/application/week_start_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/weekly_bar_chart.dart';
import '../application/analytics_clock_provider.dart';
import '../application/analytics_set_records_provider.dart';
import '../application/date_range_provider.dart';
import 'date_range_selector.dart';

/// The Insights tab (`F-NAV-001`) — overall and per-muscle weekly volume
/// (`F-ANA-004`) and hard sets per muscle per week (`F-ANA-005`), the two
/// metrics no per-exercise screen can answer on its own.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(analyticsSetRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: records.view(
        (records) => records.isEmpty
            ? const _NoDataYet()
            : _InsightsBody(records: records),
      ),
    );
  }
}

class _NoDataYet extends StatelessWidget {
  const _NoDataYet();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No sessions yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Log a few workouts to see volume and muscle coverage here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

class _InsightsBody extends ConsumerStatefulWidget {
  const _InsightsBody({required this.records});

  final List<AnalyticsSetRecord> records;

  @override
  ConsumerState<_InsightsBody> createState() => _InsightsBodyState();
}

class _InsightsBodyState extends ConsumerState<_InsightsBody> {
  Muscle _selectedMuscle = Muscle.chest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selection = ref.watch(dateRangeSelectionProvider);
    final weekStart = ref.watch(weekStartProvider);
    final prefs = ref.watch(unitPreferencesProvider);
    final now = ref.watch(analyticsClockProvider)();

    final range = resolveRange(selection.preset, now, custom: selection.custom);
    final inRange = widget.records
        .where((r) => range.contains(r.date))
        .toList();
    final rangeLabel = _rangeLabel(selection.preset);
    final muscleName = _selectedMuscle.name;

    final overallVolume = weeklyVolume(inRange, weekStart: weekStart);
    final muscleVolume = weeklyVolume(
      inRange,
      weekStart: weekStart,
      muscle: muscleName,
    );
    final setsByMuscle = setsPerMuscleByWeek(inRange, weekStart: weekStart);
    final muscleSets = setsByMuscle[muscleName] ?? const [];
    final contributors = contributingExercises(inRange, muscle: muscleName);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.screen),
      children: [
        const DateRangeSelector(),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Text(
            'Overall weekly volume',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: WeeklyBarChart(
            points: [
              for (final p in overallVolume)
                WeeklyBarPoint(
                  value: Mass.grams(p.volumeGrams).toUnit(prefs.load),
                  label: DateFormat.MMMd().format(p.weekStart),
                ),
            ],
            subtitle: '$rangeLabel · ${prefs.load.symbol}',
            valueLabel: (v) => v.toStringAsFixed(0),
          ),
        ),
        const Divider(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('By muscle', style: theme.textTheme.titleMedium),
              DropdownButton<Muscle>(
                value: _selectedMuscle,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedMuscle = value);
                },
                items: [
                  for (final muscle in Muscle.values)
                    DropdownMenuItem(value: muscle, child: Text(muscle.label)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Text(
            'Volume — ${_selectedMuscle.label}',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: WeeklyBarChart(
            points: [
              for (final p in muscleVolume)
                WeeklyBarPoint(
                  value: Mass.grams(p.volumeGrams).toUnit(prefs.load),
                  label: DateFormat.MMMd().format(p.weekStart),
                ),
            ],
            subtitle: '$rangeLabel · ${prefs.load.symbol}',
            valueLabel: (v) => v.toStringAsFixed(0),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Text(
            'Hard sets per week — ${_selectedMuscle.label}',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: WeeklyBarChart(
            points: [
              for (final p in muscleSets)
                WeeklyBarPoint(
                  value: p.sets,
                  label: DateFormat.MMMd().format(p.weekStart),
                ),
            ],
            subtitle: rangeLabel,
            valueLabel: (v) => v.toStringAsFixed(1),
          ),
        ),
        if (contributors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Text(
              'Contributing exercises',
              style: theme.textTheme.labelLarge,
            ),
          ),
          for (final contributor in contributors)
            ListTile(
              dense: true,
              title: Text(contributor.exerciseName),
              trailing: Text(
                '${contributor.sets.toStringAsFixed(1)} sets',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ],
    );
  }

  static String _rangeLabel(RangePreset preset) => switch (preset) {
    RangePreset.fourWeeks => 'Last 4 weeks',
    RangePreset.threeMonths => 'Last 3 months',
    RangePreset.sixMonths => 'Last 6 months',
    RangePreset.oneYear => 'Last year',
    RangePreset.allTime => 'All time',
    RangePreset.custom => 'Custom range',
  };
}
