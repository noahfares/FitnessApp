import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/timing/rest_timer.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../logging/application/active_workout_providers.dart';
import '../application/rest_timer_providers.dart';

/// ±15 s per tap (`F-TIM-001` §2). Two taps is a minute and a half either way,
/// which covers every real adjustment without a picker.
const int restAdjustStepSeconds = 15;

/// The rest timer, on screen for as long as it is running (`F-TIM-001` §1).
///
/// Renders nothing when no rest is running, so the caller can place it
/// unconditionally and the layout only changes when there is something to say.
///
/// Everything here is derived from [restTimerProvider] and the shared clock
/// tick. The widget holds no timer of its own — a `Timer` in widget state would
/// stop with the widget, and the rest does not.
class RestTimerBar extends ConsumerWidget {
  const RestTimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(restTimerVisibleProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final timer = ref.watch(restTimerProvider);
    final remaining = ref.watch(restRemainingProvider);
    final controller = ref.read(restTimerProvider.notifier);
    final now = ref.watch(clockTickProvider).value ?? DateTime.now();

    return Semantics(
      container: true,
      label: l10n.restTimerBarSemanticLabel(_spokenRemaining(l10n, remaining)),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _AdjustButton(
                  seconds: -restAdjustStepSeconds,
                  onPressed: () => controller.adjust(-restAdjustStepSeconds),
                ),
                Expanded(
                  child: GestureDetector(
                    // Long-press restarts: the same gesture as elsewhere for
                    // "I meant the whole thing again", and hard to hit by
                    // accident with a bar in the thumb zone.
                    onLongPress: controller.restart,
                    child: Text(
                      formatCountdown(remaining),
                      textAlign: TextAlign.center,
                      // Readable at arm's length from a bench, which is the
                      // actual usage position (`F-TIM-001` §3).
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                _AdjustButton(
                  seconds: restAdjustStepSeconds,
                  onPressed: () => controller.adjust(restAdjustStepSeconds),
                ),
                IconButton(
                  tooltip: timer.isPaused
                      ? l10n.restTimerBarResumeTooltip
                      : l10n.restTimerBarPauseTooltip,
                  onPressed: timer.isPaused
                      ? controller.resume
                      : controller.pause,
                  icon: Icon(timer.isPaused ? Icons.play_arrow : Icons.pause),
                ),
                IconButton(
                  tooltip: l10n.restTimerBarSkipTooltip,
                  onPressed: controller.skip,
                  icon: const Icon(Icons.stop),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: timer.progressAt(now.millisecondsSinceEpoch),
                minHeight: 4,
                backgroundColor: theme.colorScheme.onSecondaryContainer
                    .withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `2:05` read aloud is "two colon zero five". Spelling it out is the
  /// difference between a usable announcement and a puzzle (`F-A11Y-001`).
  static String _spokenRemaining(AppLocalizations l10n, Duration remaining) {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60);
    final parts = [
      if (minutes > 0) l10n.restTimerBarMinutes(minutes),
      if (seconds > 0) l10n.restTimerBarSeconds(seconds),
    ];
    return parts.isEmpty ? l10n.restTimerBarNoTime : parts.join(' ');
  }
}

class _AdjustButton extends StatelessWidget {
  const _AdjustButton({required this.seconds, required this.onPressed});

  final int seconds;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = '${seconds.isNegative ? '−' : '+'}${seconds.abs()}';
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(
          AppSpacing.minTouchTarget,
          AppSpacing.minTouchTarget,
        ),
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      child: Semantics(
        label: seconds.isNegative
            ? l10n.restTimerBarSubtractSemanticLabel(seconds.abs())
            : l10n.restTimerBarAddSemanticLabel(seconds),
        excludeSemantics: true,
        child: Text(label),
      ),
    );
  }
}
