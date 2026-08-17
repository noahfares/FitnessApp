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
import '../../../domain/analytics/intensity_distribution.dart';
import '../../../domain/analytics/muscle_balance.dart';
import '../../../domain/analytics/muscle_heat.dart';
import '../../../domain/analytics/sets_per_muscle.dart';
import '../../../domain/analytics/weekly_volume.dart';
import '../../../domain/catalog/muscle_taxonomy.dart' show BodyMapView;
import '../../catalog/presentation/exercise_labels.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../settings/application/week_start_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/body_map_heat_overlay.dart';
import '../../shell/widgets/trend_chart.dart';
import '../../shell/widgets/weekly_bar_chart.dart';
import '../application/acwr_provider.dart';
import '../application/analytics_clock_provider.dart';
import '../application/analytics_set_records_provider.dart';
import '../application/date_range_provider.dart';
import '../application/duration_compliance_provider.dart';
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
        const SizedBox(height: AppSpacing.lg),
        const _AcwrSection(),
        const Divider(height: AppSpacing.xl),
        _MuscleHeatSection(records: inRange),
        const Divider(height: AppSpacing.xl),
        const _DurationComplianceSection(),
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
            metricLabel: 'Overall weekly volume',
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
            metricLabel: 'Weekly volume for the selected muscle',
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
            metricLabel: 'Hard sets per week for the selected muscle',
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
        const Divider(height: AppSpacing.xl),
        _TrainingPatternsSection(records: inRange, rangeLabel: rangeLabel),
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

/// Acute:chronic workload ratio (`F-ANA-010`) — presented as information
/// only, never a warning (§8 rule 4): the injury-risk literature behind it
/// is genuinely contested, so this states what the number is and lets the
/// user judge, the same way the muscle-balance ratios above it are labelled
/// "a rough guide, not a prescription".
class _AcwrSection extends ConsumerWidget {
  const _AcwrSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final acwr = ref.watch(acwrProvider);

    return acwr.view(
      (result) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Training load', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            if (result == null || result.ratio == null)
              Text(
                'Needs at least 28 days of logged training to show.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              Text(
                '${result.ratio!.toStringAsFixed(2)} : 1',
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                'Ratio of this week\'s volume to your trailing 4-week '
                'average (ACWR). 0.8–1.3 is typically described as a steady '
                'ramp rate; this is information, not a warning.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Session duration trend and rest compliance (`F-ANA-012`) — "drifting rest
/// times explain a lot of apparent plateaus," per the feature's own doc.
/// Unscoped by the date range selector above (session duration wants the
/// full history a trend needs, not a truncated recent window) — same
/// reasoning `TrendChart`'s own 3-point minimum already assumes.
///
/// Collapsed by default behind an `ExpansionTile` — the same fix
/// `F-ROU-011`'s own preview card needed once its chart's fixed height
/// started starving whatever the list rendered below it; this screen's own
/// widget test caught the identical starvation the moment this section was
/// added uncollapsed.
class _DurationComplianceSection extends ConsumerWidget {
  const _DurationComplianceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final duration = ref.watch(sessionDurationTrendProvider).value ?? const [];
    final complianceRatio = ref.watch(restComplianceProvider).value;
    final complianceLabel = complianceRatio == null
        ? 'not enough logged rest yet'
        : '${(complianceRatio * 100).round()}% of prescribed rest';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        title: Text('Duration & rest', style: theme.textTheme.titleMedium),
        subtitle: Text(complianceLabel),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Session duration', style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
          TrendChart(
            metricLabel: 'Session duration in minutes',
            points: [
              for (var i = 0; i < duration.length; i++)
                TrendChartPoint(
                  x: i.toDouble(),
                  y: duration[i].durationSeconds / 60,
                  label: DateFormat.MMMd().format(duration[i].date),
                ),
            ],
            valueLabel: (v) => '${v.toStringAsFixed(0)} min',
            subtitle: 'Every finished session',
            zoomEnabled: false,
          ),
          const SizedBox(height: AppSpacing.md),
          if (complianceRatio != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Average actual rest vs. each exercise\'s resolved default — '
                'an approximation, not a per-set historical record.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// Body map heat overlay (`F-ANA-014`) — an original, non-anatomical
/// silhouette shaded by [records]' relative training volume per muscle.
/// Collapsed by default, same reasoning as [_DurationComplianceSection].
class _MuscleHeatSection extends ConsumerStatefulWidget {
  const _MuscleHeatSection({required this.records});

  final List<AnalyticsSetRecord> records;

  @override
  ConsumerState<_MuscleHeatSection> createState() => _MuscleHeatSectionState();
}

class _MuscleHeatSectionState extends ConsumerState<_MuscleHeatSection> {
  BodyMapView _view = BodyMapView.front;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intensity = muscleHeatIntensity(widget.records);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        title: Text('Muscle heat map', style: theme.textTheme.titleMedium),
        subtitle: const Text('Relative training volume by muscle'),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: SegmentedButton<BodyMapView>(
              segments: const [
                ButtonSegment(value: BodyMapView.front, label: Text('Front')),
                ButtonSegment(value: BodyMapView.back, label: Text('Back')),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Relative to your hardest-trained muscle over the selected '
              'range.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          BodyMapHeatOverlay(view: _view, intensity: intensity),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// Rep-range and intensity distribution (`F-ANA-011`) over the selected date
/// range — reveals a program that claims to be "strength focused" but is
/// actually running everything at 8–12.
class _TrainingPatternsSection extends ConsumerWidget {
  const _TrainingPatternsSection({
    required this.records,
    required this.rangeLabel,
  });

  final List<AnalyticsSetRecord> records;
  final String rangeLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final weightRepsSets = records.where(
      (r) =>
          r.trackingType == 'weightReps' &&
          r.setType != 'warmup' &&
          r.isCompleted &&
          r.weightGrams != null &&
          r.reps != null,
    );

    final repCounts = repRangeDistribution([
      for (final r in weightRepsSets) r.reps!,
    ]);
    final intensityCounts = intensityZoneDistribution([
      for (final r in weightRepsSets)
        IntensitySample(
          exerciseId: r.exerciseId,
          date: r.date,
          weightGrams: r.weightGrams!,
          reps: r.reps!,
        ),
    ]);
    final rpeCounts = rpeDistribution([
      for (final r in weightRepsSets)
        IntensitySample(
          exerciseId: r.exerciseId,
          date: r.date,
          weightGrams: r.weightGrams!,
          reps: r.reps!,
          rpe: r.rpe,
        ),
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Text('Rep ranges', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: WeeklyBarChart(
            metricLabel: 'Sets by rep range',
            points: [
              for (final bucket in RepRangeBucket.values)
                WeeklyBarPoint(
                  value: (repCounts[bucket] ?? 0).toDouble(),
                  label: _repRangeLabel(bucket),
                ),
            ],
            subtitle: '$rangeLabel · sets by rep range',
            valueLabel: (v) => v.toStringAsFixed(0),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Text(
            'Intensity (% of e1RM)',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: WeeklyBarChart(
            metricLabel: 'Sets by intensity zone',
            points: [
              for (final zone in IntensityZone.values)
                WeeklyBarPoint(
                  value: (intensityCounts[zone] ?? 0).toDouble(),
                  label: _intensityZoneLabel(zone),
                ),
            ],
            subtitle: '$rangeLabel · sets with a known e1RM baseline',
            valueLabel: (v) => v.toStringAsFixed(0),
          ),
        ),
        if (rpeCounts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Text('Intensity (RPE)', style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Text(
              'A more honest measure than an e1RM estimate, where logged.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: WeeklyBarChart(
              metricLabel: 'Sets by logged RPE',
              points: [
                for (final rpe in (rpeCounts.keys.toList()..sort()))
                  WeeklyBarPoint(
                    value: rpeCounts[rpe]!.toDouble(),
                    label: rpe.toStringAsFixed(1),
                  ),
              ],
              subtitle: '$rangeLabel · sets by RPE',
              valueLabel: (v) => v.toStringAsFixed(0),
            ),
          ),
        ],
      ],
    );
  }

  static String _repRangeLabel(RepRangeBucket bucket) => switch (bucket) {
    RepRangeBucket.strength => '1–3',
    RepRangeBucket.strengthHypertrophy => '4–6',
    RepRangeBucket.hypertrophy => '7–12',
    RepRangeBucket.hypertrophyEndurance => '13–20',
    RepRangeBucket.endurance => '21+',
  };

  static String _intensityZoneLabel(IntensityZone zone) => switch (zone) {
    IntensityZone.under60 => '<60%',
    IntensityZone.from60to70 => '60–70%',
    IntensityZone.from70to80 => '70–80%',
    IntensityZone.from80to90 => '80–90%',
    IntensityZone.over90 => '90%+',
  };
}
