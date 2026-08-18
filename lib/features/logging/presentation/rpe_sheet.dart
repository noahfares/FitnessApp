import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../domain/logging/rpe.dart';
import '../../settings/application/rpe_settings_provider.dart';
import '../../../core/l10n/l10n.dart';

/// RPE (or RIR) picker, from a tap on the set row's RPE cell (`F-LOG-014`).
Future<void> showRpeSheet(BuildContext context, {required WorkoutSet set}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => RpeSheet(set: set),
  );
}

/// Nine fixed steps as a grid rather than a scrolling list — there is no
/// natural "recent" ordering the way set types have, and a grid keeps every
/// option one tap away.
///
/// Options are always laid out easiest-to-hardest by canonical RPE
/// (`F-LOG-014` §2); only the printed label changes with the display mode, so
/// a value near the top always means "went easier" in either scale.
class RpeSheet extends ConsumerWidget {
  const RpeSheet({super.key, required this.set});

  final WorkoutSet set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(rpeSettingsProvider).displayMode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.screen,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mode == RpeDisplayMode.rpe ? 'RPE' : 'RIR',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              mode == RpeDisplayMode.rpe
                  ? context.l10n.loggingRateOfPerceivedExertionHigher
                  : context.l10n.loggingRepsInReserveLowerIs,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final rpe in rpeSteps)
                  _RpeChip(
                    label: formatRpeValue(
                      mode == RpeDisplayMode.rpe ? rpe : rpeToRir(rpe),
                    ),
                    selected: set.rpe == rpe,
                    onTap: () => unawaited(_pick(context, ref, rpe)),
                  ),
                if (set.rpe != null)
                  _RpeChip(
                    label: 'Clear',
                    selected: false,
                    onTap: () => unawaited(_pick(context, ref, null)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref, double? rpe) async {
    await ref.read(setRepositoryProvider).setRpe(set.id, rpe);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _RpeChip extends StatelessWidget {
  const _RpeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
