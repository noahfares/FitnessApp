import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Every destructive action names exactly what will be lost, in a sheet
/// rather than a centred dialog — pickers and confirmations land in the thumb
/// zone the same way (`F-NAV-006`, docs/23-NAVIGATION.md
/// §navigation-invariants).
///
/// Returns `true` only if the confirming action was tapped; a dismissed sheet
/// (tap outside, swipe down, back button) is the same as Cancel.
///
/// [confirmLabel]/[cancelLabel] default to null rather than a literal
/// string default value — a parameter default has to be a compile-time
/// constant, and the localized default can only be resolved once [context]
/// is available, so it's resolved in the body instead (F-I18N-001).
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool isDestructive = true,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (context) => ConfirmSheet(
      title: title,
      message: message,
      confirmLabel: confirmLabel ?? l10n.confirmSheetDeleteLabel,
      cancelLabel: cancelLabel ?? l10n.confirmSheetKeepItLabel,
      isDestructive: isDestructive,
    ),
  );
  return result ?? false;
}

class ConfirmSheet extends StatelessWidget {
  const ConfirmSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    style: isDestructive
                        ? FilledButton.styleFrom(
                            backgroundColor: context.appColors.danger,
                            foregroundColor: context.appColors.onDanger,
                          )
                        : null,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
