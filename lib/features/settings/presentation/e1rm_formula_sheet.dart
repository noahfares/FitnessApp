import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/analytics/e1rm.dart';
import '../application/e1rm_formula_provider.dart';
import '../../../core/l10n/l10n.dart';
import '../../../l10n/app_localizations.dart';

/// The e1RM formula picker (`F-SET-006`) — opened from the trend chart's app
/// bar, since that's the one place the choice is actually visible.
Future<void> showE1rmFormulaSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => const E1rmFormulaSheet(),
  );
}

class E1rmFormulaSheet extends ConsumerWidget {
  const E1rmFormulaSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final current = ref.watch(e1rmFormulaProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.xs,
            ),
            child: Text(
              context.l10n.settingsE1rmFormula,
              style: theme.textTheme.titleMedium,
            ),
          ),
          for (final formula in E1rmFormula.values)
            ListTile(
              leading: Icon(
                current == formula
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(_title(formula, context.l10n)),
              subtitle: Text(_subtitle(formula, context.l10n)),
              onTap: () async {
                await ref.read(e1rmFormulaProvider.notifier).set(formula);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  static String _title(E1rmFormula formula, AppLocalizations l10n) =>
      switch (formula) {
        E1rmFormula.epley => l10n.settingsEpleyDefault,
        E1rmFormula.brzycki => 'Brzycki',
        E1rmFormula.lombardi => 'Lombardi',
      };

  static String _subtitle(E1rmFormula formula, AppLocalizations l10n) =>
      switch (formula) {
        E1rmFormula.epley => l10n.settingsW1Reps30,
        E1rmFormula.brzycki => l10n.settingsW3637Reps,
        E1rmFormula.lombardi => l10n.settingsWReps010,
      };
}
