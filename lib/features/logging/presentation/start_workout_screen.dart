import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../routines/application/routine_providers.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/active_workout_providers.dart';
import '../../../core/l10n/l10n.dart';

/// Starts a session, or offers a way out of the one already running
/// (`F-LOG-001`).
///
/// Presented as a modal sheet from the centre tab (docs/23-NAVIGATION.md) and
/// as a full screen when reached by deep link, so a home-screen shortcut
/// (`F-NAV-008`) lands somewhere sensible rather than on a stray sheet.
class StartWorkoutScreen extends StatelessWidget {
  const StartWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.loggingStart)),
      body: const SafeArea(child: StartWorkoutBody()),
    );
  }
}

/// Shows the start sheet over whatever is on screen.
Future<void> showStartWorkoutSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (context) => const SafeArea(child: StartWorkoutBody()),
  );
}

class StartWorkoutBody extends ConsumerWidget {
  const StartWorkoutBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final active = ref.watch(activeWorkoutProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (active != null) ...[
            // Starting a second workout is refused, not resolved silently:
            // which session was meant to survive is not the app's call
            // (`F-LOG-001` §3).
            Text(
              context.l10n.historyAlreadyTraining,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.loggingAlreadyTrainingExplainer(active.name),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).maybePop();
                context.go(AppRoutes.activeWorkout);
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(context.l10n.loggingResumeWorkout),
            ),
          ] else ...[
            Text(
              context.l10n.loggingStartAWorkout,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.loggingAnEmptySessionYouAdd,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => unawaited(_start(context, ref)),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.loggingStartEmptyWorkout),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.l10n.loggingOrStartFromARoutine,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _RoutineDayList(),
          ],
        ],
      ),
    );
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    await ref.read(workoutRepositoryProvider).start();
    if (!context.mounted) return;
    // Close the sheet first if we are in one, so the session is not left
    // underneath it.
    await Navigator.of(context).maybePop();
    if (!context.mounted) return;
    context.go(AppRoutes.activeWorkout);
  }
}

/// Every startable day, grouped under its routine (`F-ROU-010`).
class _RoutineDayList extends ConsumerWidget {
  const _RoutineDayList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider).value ?? const [];
    if (routines.isEmpty) {
      return EmptyState(
        icon: Icons.checklist_outlined,
        title: context.l10n.loggingNoRoutinesYet,
        message: context.l10n.loggingBuildOneFromTheRoutines,
      );
    }
    return Column(
      children: [
        for (final routine in routines) _RoutineDaysSection(routine: routine),
      ],
    );
  }
}

class _RoutineDaysSection extends ConsumerWidget {
  const _RoutineDaysSection({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(routineDaysProvider(routine.id)).value ?? const [];
    if (days.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Text(
                routine.name,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            for (final day in days)
              ListTile(
                title: Text(day.name),
                trailing: const Icon(Icons.play_arrow),
                onTap: () => unawaited(_start(context, ref, day.id)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context, WidgetRef ref, String dayId) async {
    final repo = ref.read(workoutRepositoryProvider);
    try {
      await repo.startFromRoutineDay(dayId);
    } on ActiveWorkoutExistsException {
      // A race with another entry point — the workout that won is still the
      // right place to land.
    }
    if (!context.mounted) return;
    await Navigator.of(context).maybePop();
    if (!context.mounted) return;
    context.go(AppRoutes.activeWorkout);
  }
}
