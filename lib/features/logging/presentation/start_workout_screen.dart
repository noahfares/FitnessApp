import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/database_provider.dart';
import '../application/active_workout_providers.dart';

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
      appBar: AppBar(title: const Text('Start')),
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

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (active != null) ...[
            // Starting a second workout is refused, not resolved silently:
            // which session was meant to survive is not the app's call
            // (`F-LOG-001` §3).
            Text('Already training', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '"${active.name}" is still in progress. Finish or discard it '
              'before starting another.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).maybePop();
                context.go(AppRoutes.activeWorkout);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume workout'),
            ),
          ] else ...[
            Text('Start a workout', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'An empty session you add exercises to as you go.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => unawaited(_start(context, ref)),
              icon: const Icon(Icons.add),
              label: const Text('Start empty workout'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Starting from a routine day arrives in Phase 2.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
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
