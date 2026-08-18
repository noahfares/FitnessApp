import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/analytics/weekly_insights.dart';
import '../../analytics/application/weekly_insights_provider.dart';
import '../../analytics/presentation/weekly_insight_text.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../../core/l10n/l10n.dart';
import 'section_header.dart';

/// The dashboard's weekly insight cards (`F-ANA-013`) — "the payoff for the
/// whole analytics layer," per the feature's own doc. Renders nothing at all
/// while loading, on error, or with too little history to say anything —
/// silent, never a placeholder, matching `_TodaysScheduleCard`'s own
/// "shrink rather than show emptiness" shape.
class WeeklyInsightsSection extends ConsumerWidget {
  const WeeklyInsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(weeklyInsightsProvider).value ?? const [];
    if (insights.isEmpty) return const SizedBox.shrink();

    final colors = context.appColors;
    final formatter = ref.watch(quantityFormatterProvider);
    final unit = ref.watch(unitPreferencesProvider).load;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(context.l10n.shellThisWeek),
          const SizedBox(height: AppSpacing.sm),
          for (final insight in insights)
            Padding(
              padding: EdgeInsets.only(
                bottom: insight == insights.last ? 0 : AppSpacing.sm,
              ),
              child: Material(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  onTap: () => _open(context, insight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Icon(_iconFor(insight.kind), color: colors.tint),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            weeklyInsightText(
                              insight,
                              formatter,
                              unit,
                              context.l10n,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: -0.16,
                              color: colors.label,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 19,
                          color: colors.labelTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconFor(InsightKind kind) => switch (kind) {
    InsightKind.muscleVolumeChange => Icons.show_chart,
    InsightKind.exerciseE1rmNewHigh => Icons.emoji_events_outlined,
    InsightKind.muscleSetsLastWeek => Icons.fitness_center,
  };

  /// Links to the chart behind the card (`F-ANA-013` §3). The two
  /// muscle-scoped kinds open the Insights tab generally rather than
  /// preselected to that muscle — `InsightsScreen`'s muscle picker is local
  /// widget state, not yet a route parameter.
  void _open(BuildContext context, WeeklyInsight insight) {
    switch (insight.kind) {
      case InsightKind.exerciseE1rmNewHigh:
        if (insight.exerciseId case final id?) {
          context.push(AppRoutes.exerciseDetail(id));
        }
      case InsightKind.muscleVolumeChange:
      case InsightKind.muscleSetsLastWeek:
        context.push(AppRoutes.insights);
    }
  }
}
