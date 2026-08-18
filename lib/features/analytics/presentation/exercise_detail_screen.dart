import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../domain/analytics/date_range.dart';
import '../../../domain/analytics/e1rm.dart';
import '../../../domain/analytics/e1rm_trend.dart';
import '../../../domain/analytics/exercise_history.dart';
import '../../../domain/analytics/stall_detection.dart';
import '../../../domain/analytics/weekly_volume.dart';
import '../../../domain/progression/deload_suggestion.dart';
import '../../settings/application/e1rm_formula_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../settings/application/week_start_provider.dart';
import '../../settings/presentation/e1rm_formula_sheet.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/empty_state.dart';
import '../../shell/widgets/trend_chart.dart';
import '../../shell/widgets/weekly_bar_chart.dart';
import '../application/acwr_provider.dart';
import '../application/analytics_clock_provider.dart';
import '../application/date_range_provider.dart';
import '../application/exercise_history_providers.dart';
import 'date_range_selector.dart';
import '../../../core/l10n/l10n.dart';
import '../../../l10n/app_localizations.dart';

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
        title: Text(
          exercise.value?.name ?? context.l10n.analyticsExerciseHistory,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.functions),
            tooltip: context.l10n.settingsE1rmFormula,
            onPressed: () => showE1rmFormulaSheet(context),
          ),
        ],
      ),
      body: history.view(
        (sessions) => sessions.isEmpty
            ? EmptyState(
                icon: Icons.history,
                title: context.l10n.analyticsNoSessionsYet,
                message: context.l10n.analyticsLogThisExerciseInA,
              )
            : _ExerciseDetailBody(
                sessions: sessions,
                exerciseName:
                    exercise.value?.name ?? context.l10n.analyticsThisExercise,
              ),
      ),
    );
  }
}

class _ExerciseDetailBody extends ConsumerWidget {
  const _ExerciseDetailBody({
    required this.sessions,
    required this.exerciseName,
  });

  final List<ExerciseHistorySession> sessions;
  final String exerciseName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(quantityFormatterProvider);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.screen),
      itemCount: sessions.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return _AnalyticsHeader(
            sessions: sessions,
            exerciseName: exerciseName,
          );
        }
        final session = sessions[i - 1];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: _SessionCard(session: session, formatter: formatter),
        );
      },
    );
  }
}

/// The shared date range selector (`F-ANA-015`) once, followed by both
/// charts that read it — the e1RM trend (`F-ANA-003`) and weekly volume
/// (`F-ANA-004`) — above the session list `F-ANA-002` already built.
class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({required this.sessions, required this.exerciseName});

  final List<ExerciseHistorySession> sessions;
  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DateRangeSelector(),
        const SizedBox(height: AppSpacing.sm),
        _TrendSection(sessions: sessions),
        const SizedBox(height: AppSpacing.md),
        _StallSection(sessions: sessions, exerciseName: exerciseName),
        const SizedBox(height: AppSpacing.md),
        _VolumeSection(sessions: sessions),
        const Divider(height: AppSpacing.xl),
      ],
    );
  }
}

/// Stall detection (`F-ANA-009`) and the deload suggestion it feeds
/// (`F-PRG-011`) — plain English, not a chart annotation (§7 rule 5), and
/// nothing at all when there's no verdict or the verdict isn't stalled
/// (`docs/50-ROADMAP.md` Phase 4 exit criterion: insight cards say nothing
/// when data is insufficient).
class _StallSection extends ConsumerWidget {
  const _StallSection({required this.sessions, required this.exerciseName});

  final List<ExerciseHistorySession> sessions;
  final String exerciseName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // The repository orders sessions newest-first; stall detection reads
    // oldest-first, over whichever sessions have a computable e1RM.
    final withE1rm = [
      for (final session in sessions.reversed)
        if (session.bestE1rmGrams case final e1rm?)
          SessionE1rm(date: session.localDate, e1rmGrams: e1rm),
    ];
    final verdict = detectStall(withE1rm);
    if (verdict == null || !verdict.stalled) return const SizedBox.shrink();

    final acwr = ref.watch(acwrProvider).value;
    final suggestion = suggestDeload(stall: verdict, acwr: acwr);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_flat,
                  color: context.appColors.labelSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    "$exerciseName hasn't moved in a while",
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.analyticsStallExplainer(verdict.windowSize),
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.appColors.labelSecondary,
              ),
            ),
            if (suggestion.suggested) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.analyticsDeloadSuggestedHeading,
                style: theme.textTheme.bodyMedium,
              ),
              for (final reason in suggestion.reasons)
                Text(
                  '•  $reason',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.appColors.labelSecondary,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The `e1RM trend` chart and its two display toggles (`F-ANA-003`).
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
          workoutId: trend[i].workoutId,
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
              Text(
                context.l10n.analyticsE1rmTrend,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                context.l10n.analyticsFormulaLabel(_formulaLabel(formula)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.appColors.labelSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: TrendChart(
            points: points,
            metricLabel: context.l10n.analyticsEstimatedOneRepMax,
            subtitle:
                '${_rangeLabel(selection.preset, context.l10n)} · ${prefs.load.symbol}',
            showRegression: _showRegression,
            valueLabel: (v) => v.toStringAsFixed(1),
            onPointTap: (point) =>
                context.push(AppRoutes.historyWorkout(point.workoutId!)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Wrap(
            children: [
              SwitchListTile(
                title: Text(context.l10n.analyticsExcludeSetsOver12Reps),
                subtitle: Text(context.l10n.analyticsUnreliableAtHighRepCounts),
                value: _excludeUnreliable,
                onChanged: (v) => setState(() => _excludeUnreliable = v),
              ),
              SwitchListTile(
                title: Text(context.l10n.analyticsTrendLine),
                subtitle: Text(context.l10n.analyticsLinearRegressionOverlay),
                value: _showRegression,
                onChanged: (v) => setState(() => _showRegression = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formulaLabel(E1rmFormula formula) => switch (formula) {
    E1rmFormula.epley => 'Epley',
    E1rmFormula.brzycki => 'Brzycki',
    E1rmFormula.lombardi => 'Lombardi',
  };
}

String _rangeLabel(RangePreset preset, AppLocalizations l10n) =>
    switch (preset) {
      RangePreset.fourWeeks => l10n.analyticsLast4Weeks,
      RangePreset.threeMonths => l10n.analyticsLast3Months,
      RangePreset.sixMonths => l10n.analyticsLast6Months,
      RangePreset.oneYear => l10n.analyticsLastYear,
      RangePreset.allTime => l10n.analyticsAllTime,
      RangePreset.custom => l10n.analyticsCustomRange,
    };

/// The weekly volume chart (`F-ANA-004`) — per-exercise volume, bucketed by
/// the shared date range and the user's week-start setting.
class _VolumeSection extends ConsumerWidget {
  const _VolumeSection({required this.sessions});

  final List<ExerciseHistorySession> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selection = ref.watch(dateRangeSelectionProvider);
    final weekStart = ref.watch(weekStartProvider);
    final prefs = ref.watch(unitPreferencesProvider);
    final now = ref.watch(analyticsClockProvider)();

    final range = resolveRange(selection.preset, now, custom: selection.custom);
    final inRange = sessions.where((s) => range.contains(s.localDate)).toList();
    final weekly = weeklyVolumeFromSessions(inRange, weekStart: weekStart);

    final points = [
      for (final point in weekly)
        WeeklyBarPoint(
          value: Mass.grams(point.volumeGrams).toUnit(prefs.load),
          label: DateFormat.MMMd().format(point.weekStart),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Text(
            context.l10n.analyticsWeeklyVolume,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: WeeklyBarChart(
            metricLabel: context.l10n.analyticsWeeklyVolume,
            points: points,
            subtitle:
                '${_rangeLabel(selection.preset, context.l10n)} · ${prefs.load.symbol}',
            valueLabel: (v) => v.toStringAsFixed(0),
          ),
        ),
      ],
    );
  }
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
                    color: context.appColors.labelSecondary,
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
                color: context.appColors.labelSecondary,
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
                        ? context.appColors.labelSecondary
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
