import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/body_providers.dart';
import 'log_bodyweight_sheet.dart';

/// The bodyweight log (`F-BOD-001`).
///
/// Only bodyweight — the rest of body metrics (circumferences, photos,
/// charts) is Phase 4. This screen exists early because the data it captures
/// is unrecoverable, not because the rest of body metrics is ready.
class BodyWeightScreen extends ConsumerWidget {
  const BodyWeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(bodyweightHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bodyweight')),
      body: history.view(
        errorTitle: 'Bodyweight history could not be read',
        (entries) => entries.isEmpty
            ? EmptyState(
                icon: Icons.monitor_weight_outlined,
                title: 'No bodyweight logged yet',
                message: 'Log your weight to track it alongside your lifts.',
                actionLabel: 'Log bodyweight',
                onAction: () => unawaited(showLogBodyweightSheet(context)),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: entries.length,
                itemBuilder: (context, i) => _BodyweightTile(entry: entries[i]),
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
