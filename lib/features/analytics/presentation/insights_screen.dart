import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/tables/enums.dart';
import '../../../domain/analytics/analytics_set_record.dart';
import '../../../domain/analytics/date_range.dart';
import '../../../domain/analytics/muscle_balance.dart';
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

  /// Set by tapping a bar on the sets-per-muscle chart (`F-ANA-016`'s
  /// per-bar tap-through). Null scopes the drill-down to the whole range,
  /// same as before this feature existed.
  DateTime? _selectedWeek;

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
    final contributors = contributingExercises(
      inRange,
      muscle: muscleName,
      week: _selectedWeek,
      weekStart: weekStart,
    );

    final trailingWindowRecords = widget.records
        .where(
          (r) => !r.date.isBefore(
            weekStart.weekStartFor(now.subtract(const Duration(days: 27))),
          ),
        )
        .toList();
    final trailingTotals = totalSetsPerMuscle(
      setsPerMuscleByWeek(trailingWindowRecords, weekStart: weekStart),
    );
    final pushPull = pushPullRatio(trailingTotals);
    final quadHamstring = quadHamstringRatio(trailingTotals);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.screen),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.consistency),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Consistency'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.prTimeline),
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: const Text('PR timeline'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Text('Muscle balance', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Text(
            'Trailing 4 weeks. A rough guide, not a prescription.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Row(
            children: [
              Expanded(
                child: _RatioTile(label: 'Push : pull', ratio: pushPull.ratio),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _RatioTile(
                  label: 'Quad : hamstring',
                  ratio: quadHamstring.ratio,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: AppSpacing.xl),
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
                  if (value != null) {
                    setState(() {
                      _selectedMuscle = value;
                      _selectedWeek = null;
                    });
                  }
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
            // Tap a bar to scope "Contributing exercises" to that one week
            // (`F-ANA-016`) — carried over from `F-ANA-005`'s own deferral.
            onBarTap: (index, _) =>
                setState(() => _selectedWeek = muscleSets[index].weekStart),
          ),
        ),
        if (contributors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedWeek == null
                      ? 'Contributing exercises'
                      : 'Contributing exercises — week of '
                            '${DateFormat.MMMd().format(_selectedWeek!)}',
                  style: theme.textTheme.labelLarge,
                ),
                if (_selectedWeek != null)
                  TextButton(
                    onPressed: () => setState(() => _selectedWeek = null),
                    child: const Text('Clear'),
                  ),
              ],
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

class _RatioTile extends StatelessWidget {
  const _RatioTile({required this.label, required this.ratio});

  final String label;

  /// `null` reports "no data recorded" rather than infinity (§9 rule 2).
  final double? ratio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ratio == null ? '—' : '${ratio!.toStringAsFixed(2)} : 1',
          style: theme.textTheme.headlineSmall,
        ),
        Text(
          ratio == null ? '$label — no data recorded' : label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
