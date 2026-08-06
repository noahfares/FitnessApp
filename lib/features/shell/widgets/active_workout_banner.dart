import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../logging/application/active_workout_providers.dart';
import '../../logging/presentation/active_workout_screen.dart'
    show formatElapsed;

/// Persistent banner above the bottom navigation while a workout is in
/// progress (`F-NAV-003`): exercise count, elapsed time, tap to return.
///
/// **Non-dismissible** — it is trivially easy to navigate away mid-session to
/// check history, and unacceptable to then have to hunt for the session
/// you're in (docs/23-NAVIGATION.md). Renders nothing when no session is
/// running, so it costs nothing to always mount in the shell.
class ActiveWorkoutBanner extends ConsumerWidget {
  const ActiveWorkoutBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(activeWorkoutProvider).value;
    if (workout == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final exercises = ref.watch(sessionExercisesProvider(workout.id)).value;
    final elapsed = ref.watch(elapsedProvider);

    return Material(
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: () => context.push(AppRoutes.activeWorkout),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 18,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${exercises?.length ?? 0} '
                    '${exercises?.length == 1 ? 'exercise' : 'exercises'} · '
                    '${formatElapsed(elapsed)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
