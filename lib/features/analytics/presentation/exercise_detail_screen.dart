import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../domain/analytics/date_range.dart';
import '../../../domain/analytics/e1rm.dart';
import '../../../domain/analytics/e1rm_trend.dart';
import '../../../domain/analytics/exercise_history.dart';
import '../../settings/application/e1rm_formula_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../settings/presentation/e1rm_formula_sheet.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/empty_state.dart';
import '../../shell/widgets/trend_chart.dart';
import '../application/analytics_clock_provider.dart';
import '../application/date_range_provider.dart';
import '../application/exercise_history_providers.dart';
import 'date_range_selector.dart';

/// The most-visited analytics screen — "what you check before you load the
/// bar" (`F-ANA-002`), now with the e1RM trend (`F-ANA-003`) above the
/// session list. Read-only: editing a past set stays the job of history's
/// own edit flow, not this one.
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({required this.exerciseId, super.key});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(exerciseByIdProvider(exerciseId));
    final history = ref.watch(exerciseHistoryProvider(exerciseId));

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.value?.name ?? 'Exercise history'),
        actions: [
          IconButton(
            icon: const Icon(Icons.functions),
            tooltip: 'e1RM formula',
            onPressed: () => showE1rmFormulaSheet(context),
          ),
        ],
      ),
      body: history.view(
        (sessions) => sessions.isEmpty
            ? const EmptyState(
                icon: Icons.history,
                title: 'No sessions yet',
                message: 'Log this exercise in a workout to see it here.',
              )
            : _ExerciseDetailBody(sessions: sessions),
      ),
    );
  }
}

class _ExerciseDetailBody extends ConsumerWidget {
  const _ExerciseDetailBody({required this.sessions});

  final List<ExerciseHistorySession> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(quantityFormatterProvider);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.screen),
      itemCount: sessions.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return _TrendSection(sessions: sessions);
        final session = sessions[i - 1];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: _SessionCard(session: session, formatter: formatter),
        );
      },
    );
  }
}

/// The `e1RM trend` chart, its date range selector, and its two display
/// toggles — everything `F-ANA-003` and `F-ANA-015` add above the session
/// list that `F-ANA-002` already built.
class _TrendSection extends ConsumerStatefulWidget {
  const _TrendSection({required this.sessions});

  final List<ExerciseHistorySession> sessions;

  @override
  ConsumerState<_TrendSection> createState() => _TrendSectionState();
}

class _TrendSectionState extends ConsumerState<_TrendSection> {
  // "Optionally excluded" (§1 rule 2) — shown by default, since compute-and-
  // mark is the rule and hiding is the option (`F-ANA-003` §3).
  bool _excludeUnreliable = false;
  bool _showRegression = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formula = ref.watch(e1rmFormulaProvider);
    final selection = ref.watch(dateRangeSelectionProvider);
    final prefs = ref.watch(unitPreferencesProvider);

    final now = ref.watch(analyticsClockProvider)();
    final range = resolveRange(selection.preset, now, custom: selection.custom);
    var trend = e1rmTrend(widget.sessions, formula: formula, range: range);
    if (_excludeUnreliable) {
      trend = trend.where((p) => p.reliable).toList();
    }

    final points = [
      for (var i = 0; i < trend.length; i++)
        TrendChartPoint(
          x: i.toDouble(),
          y: Mass.grams(trend[i].e1rmGrams).toUnit(prefs.load),
          label: DateFormat.MMMd().format(trend[i].date),
          reliable: trend[i].reliable,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('e1RM trend', style: theme.textTheme.titleMedium),
              Text(
                'Formula: ${_formulaLabel(formula)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const DateRangeSelector(),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: TrendChart(
            points: points,
            subtitle: '${_rangeLabel(selection.preset)} · ${prefs.load.symbol}',
            showRegression: _showRegression,
            valueLabel: (v) => v.toStringAsFixed(1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Wrap(
            children: [
              SwitchListTile(
                title: const Text('Exclude sets over 12 reps'),
                subtitle: const Text('Unreliable at high rep counts'),
                value: _excludeUnreliable,
                onChanged: (v) => setState(() => _excludeUnreliable = v),
              ),
              SwitchListTile(
                title: const Text('Trend line'),
                subtitle: const Text('Linear regression overlay'),
                value: _showRegression,
                onChanged: (v) => setState(() => _showRegression = v),
              ),
            ],
          ),
        ),
        const Divider(height: AppSpacing.xl),
      ],
    );
  }

  static String _formulaLabel(E1rmFormula formula) => switch (formula) {
    E1rmFormula.epley => 'Epley',
    E1rmFormula.brzycki => 'Brzycki',
    E1rmFormula.lombardi => 'Lombardi',
  };

  static String _rangeLabel(RangePreset preset) => switch (preset) {
    RangePreset.fourWeeks => 'Last 4 weeks',
    RangePreset.threeMonths => 'Last 3 months',
    RangePreset.sixMonths => 'Last 6 months',
    RangePreset.oneYear => 'Last year',
    RangePreset.allTime => 'All time',
    RangePreset.custom => 'Custom range',
  };
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.formatter});

  final ExerciseHistorySession session;
  final QuantityFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bestSet = session.bestSet;
    final bestE1rm = session.bestE1rmGrams;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMd().format(session.localDate),
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  session.workoutName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (bestSet != null && bestSet.weightGrams != null)
              Text(
                'Best set: ${formatter.setWeight(Mass.grams(bestSet.weightGrams!), showUnit: true)} × ${bestSet.reps}'
                '${bestE1rm != null ? '  ·  e1RM ${formatter.e1rm(Mass.grams(bestE1rm))}' : ''}',
                style: theme.textTheme.bodyMedium,
              ),
            Text(
              'Volume ${formatter.volume(Mass.grams(session.volumeGrams))}'
              '  ·  ${session.countedSets.length} counted set'
              '${session.countedSets.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final set in session.sets)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs / 2),
                child: Text(
                  _setLine(set, formatter),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: set.setType == 'warmup' || !set.isCompleted
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _setLine(ExerciseHistorySet set, QuantityFormatter formatter) {
    final label = set.setType == 'warmup' ? 'Warm-up' : 'Set';
    final value = set.weightGrams != null && set.reps != null
        ? '${formatter.setWeight(Mass.grams(set.weightGrams!), showUnit: true)} × ${set.reps}'
        : '—';
    return set.isCompleted ? '$label · $value' : '$label · $value (planned)';
  }
}
