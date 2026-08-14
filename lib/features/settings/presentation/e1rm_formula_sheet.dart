import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/analytics/e1rm.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/e1rm_formula_provider.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.e1rmFormulaTitle,
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
              title: Text(_title(l10n, formula)),
              subtitle: Text(_subtitle(formula)),
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

  static String _title(AppLocalizations l10n, E1rmFormula formula) =>
      switch (formula) {
        E1rmFormula.epley => l10n.e1rmFormulaEpleyName,
        E1rmFormula.brzycki => l10n.e1rmFormulaBrzyckiName,
        E1rmFormula.lombardi => l10n.e1rmFormulaLombardiName,
      };

  static String _subtitle(E1rmFormula formula) => switch (formula) {
    E1rmFormula.epley => 'w × (1 + reps / 30)',
    E1rmFormula.brzycki => 'w × 36 / (37 − reps)',
    E1rmFormula.lombardi => 'w × reps^0.10',
  };
}
