import 'dart:async';

import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/length.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart';
import '../../settings/application/tracked_measurements_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../../shell/widgets/trend_chart.dart';
import '../application/body_providers.dart';
import 'log_bodyweight_sheet.dart';
import 'log_measurement_sheet.dart';
import 'measurement_labels.dart';
import 'tracked_measurements_sheet.dart';

/// The body screen: bodyweight (`F-BOD-001`), its EMA trend (`F-BOD-003`),
/// and whichever circumference/body-fat measurements have been opted into
/// (`F-BOD-002`).
class BodyWeightScreen extends ConsumerWidget {
  const BodyWeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(bodyweightHistoryProvider);
    final tracked = ref.watch(trackedMeasurementTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body'),
        actions: [
          IconButton(
            tooltip: 'Progress photos',
            icon: const Icon(Icons.photo_camera_outlined),
            onPressed: () => context.push(AppRoutes.bodyPhotos),
          ),
          IconButton(
            tooltip: 'Measurements to track',
            icon: const Icon(Icons.tune),
            onPressed: () => unawaited(showTrackedMeasurementsSheet(context)),
          ),
        ],
      ),
      body: history.view(
        errorTitle: 'Bodyweight history could not be read',
        (entries) => ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            if (entries.isEmpty)
              EmptyState(
                icon: Icons.monitor_weight_outlined,
                title: 'No bodyweight logged yet',
                message: 'Log your weight to track it alongside your lifts.',
                actionLabel: 'Log bodyweight',
                onAction: () => unawaited(showLogBodyweightSheet(context)),
              )
            else ...[
              const _BodyweightTrendSection(),
              for (final entry in entries) _BodyweightTile(entry: entry),
            ],
            if (tracked.isNotEmpty)
              for (final type in trackableMeasurementTypes)
                if (tracked.contains(type)) _MeasurementSection(type: type),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(showLogBodyweightSheet(context)),
        icon: const Icon(Icons.add),
        label: const Text('Log bodyweight'),
      ),
    );
  }
}

class _BodyweightTrendSection extends ConsumerWidget {
  const _BodyweightTrendSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trendAsync = ref.watch(bodyweightTrendProvider);
    final unit = ref.watch(unitPreferencesProvider).body;
    final formatter = ref.watch(quantityFormatterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.md,
      ),
      child: trendAsync.view((trend) {
        final points = [
          for (var i = 0; i < trend.points.length; i++)
            TrendChartPoint(
              x: i.toDouble(),
              y: Mass.grams(trend.points[i].emaGrams.round()).toUnit(unit),
              label: DateFormat.MMMd().format(
                DateTime.fromMillisecondsSinceEpoch(
                  trend.points[i].measuredAtEpochMs,
                ),
              ),
            ),
        ];
        final raw = [
          for (var i = 0; i < trend.points.length; i++)
            TrendChartPoint(
              x: i.toDouble(),
              y: Mass.grams(trend.points[i].rawGrams).toUnit(unit),
              label: '',
            ),
        ];
        final rate = trend.weeklyRateGrams;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trend', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            TrendChart(
              points: points,
              metricLabel: 'Bodyweight trend',
              secondaryPoints: raw,
              subtitle: unit.symbol,
              valueLabel: (v) => v.toStringAsFixed(1),
              zoomEnabled: false,
            ),
            if (rate != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${rate >= 0 ? '+' : ''}'
                '${formatter.massValueOnly(Mass.grams(rate.round()), unit)} '
                '${unit.symbol}/week',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _BodyweightTile extends ConsumerWidget {
  const _BodyweightTile({required this.entry});

  final BodyMeasurement entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(quantityFormatterProvider);
    final date = DateTime.fromMillisecondsSinceEpoch(entry.measuredAt);

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showConfirmSheet(
        context,
        title: 'Delete this entry?',
        message:
            '${DateFormat.yMMMd().format(date)}\'s bodyweight entry will '
            'be removed.',
      ),
      onDismissed: (_) => unawaited(
        ref.read(bodyMeasurementRepositoryProvider).deleteBodyweight(entry.id),
      ),
      background: Container(
        alignment: Alignment.centerRight,
        color: context.appColors.danger,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Icon(Icons.delete_outline, color: context.appColors.onDanger),
      ),
      child: ListTile(
        title: Text(formatter.bodyweight(Mass.grams(entry.valueCanonical))),
        subtitle: Text(
          entry.notes == null
              ? DateFormat.yMMMd().format(date)
              : '${DateFormat.yMMMd().format(date)} · ${entry.notes}',
        ),
        trailing: const Icon(Icons.edit_outlined),
        onTap: () => unawaited(showLogBodyweightSheet(context, editing: entry)),
      ),
    );
  }
}

/// One tracked measurement type's section: its latest value, and its full
/// history below (`F-BOD-002`).
class _MeasurementSection extends ConsumerWidget {
  const _MeasurementSection({required this.type});

  final MeasurementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final history = ref.watch(measurementHistoryProvider(type));

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(type.label, style: theme.textTheme.titleSmall),
                IconButton(
                  tooltip: 'Log ${type.label}',
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () =>
                      unawaited(showLogMeasurementSheet(context, type: type)),
                ),
              ],
            ),
          ),
          history.view(
            (entries) => entries.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screen,
                    ),
                    child: Text(
                      'Not logged yet.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final entry in entries)
                        _MeasurementTile(type: type, entry: entry),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementTile extends ConsumerWidget {
  const _MeasurementTile({required this.type, required this.entry});

  final MeasurementType type;
  final BodyMeasurement entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(quantityFormatterProvider);
    final date = DateTime.fromMillisecondsSinceEpoch(entry.measuredAt);
    final value = type.isPercent
        ? formatter.percent(entry.valueCanonical)
        : formatter.circumference(Length.millimetres(entry.valueCanonical));

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showConfirmSheet(
        context,
        title: 'Delete this entry?',
        message:
            "${DateFormat.yMMMd().format(date)}'s ${type.label.toLowerCase()} "
            'entry will be removed.',
      ),
      onDismissed: (_) => unawaited(
        ref.read(bodyMeasurementRepositoryProvider).deleteMeasurement(entry.id),
      ),
      background: Container(
        alignment: Alignment.centerRight,
        color: context.appColors.danger,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Icon(Icons.delete_outline, color: context.appColors.onDanger),
      ),
      child: ListTile(
        title: Text(value),
        subtitle: Text(
          entry.notes == null
              ? DateFormat.yMMMd().format(date)
              : '${DateFormat.yMMMd().format(date)} · ${entry.notes}',
        ),
        trailing: const Icon(Icons.edit_outlined),
        onTap: () => unawaited(
          showLogMeasurementSheet(context, type: type, editing: entry),
        ),
      ),
    );
  }
}
