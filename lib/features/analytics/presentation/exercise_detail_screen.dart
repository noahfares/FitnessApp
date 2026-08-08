import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../domain/analytics/exercise_history.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/exercise_history_providers.dart';

/// The most-visited analytics screen — "what you check before you load the
/// bar" (`F-ANA-002`). Read-only: editing a past set stays the job of
/// history's own edit flow, not this one.
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({required this.exerciseId, super.key});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(exerciseByIdProvider(exerciseId));
    final history = ref.watch(exerciseHistoryProvider(exerciseId));

    return Scaffold(
      appBar: AppBar(title: Text(exercise.value?.name ?? 'Exercise history')),
      body: history.view(
        (sessions) => sessions.isEmpty
            ? const EmptyState(
                icon: Icons.history,
                title: 'No sessions yet',
                message: 'Log this exercise in a workout to see it here.',
              )
            : _SessionList(sessions: sessions),
      ),
    );
  }
}

class _SessionList extends ConsumerWidget {
  const _SessionList({required this.sessions});

  final List<ExerciseHistorySession> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(quantityFormatterProvider);
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screen),
      itemCount: sessions.length,
      itemBuilder: (context, i) =>
          _SessionCard(session: sessions[i], formatter: formatter),
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
