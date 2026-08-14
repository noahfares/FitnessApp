import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../application/app_lock_provider.dart';

/// Set, change or remove the app-lock PIN (`F-SET-010`).
///
/// **A UI gate, not encryption at rest** — see `PinHasher`'s own doc for
/// the full reasoning. Biometric unlock (the spec's other option) is not
/// built: `local_auth` needs platform manifest/entitlement work this
/// session's toolchain (no Android SDK, no device) can't responsibly add
/// without verifying it, the same class of deferral as `F-TIM-003`'s
/// background notification.
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasLock = ref.watch(hasAppLockProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appLockTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appLockDescription, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => unawaited(_setOrChangePin(hasLock)),
              child: Text(
                hasLock
                    ? l10n.appLockChangePinAction
                    : l10n.appLockSetPinAction,
              ),
            ),
            if (hasLock) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => unawaited(_removePin()),
                child: Text(l10n.appLockRemovePinAction),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _setOrChangePin(bool hasExisting) async {
    final l10n = AppLocalizations.of(context)!;
    if (hasExisting) {
      final current = await _promptForPin(l10n.appLockEnterCurrentPinTitle);
      if (current == null) return;
      final valid = ref.read(appLockNotifierProvider).verify(current);
      if (!valid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.appLockWrongPinMessage)));
        return;
      }
    }

    if (!mounted) return;
    final pin = await _promptForPin(l10n.appLockChoosePinTitle);
    if (pin == null || pin.length < 4) return;
    if (!mounted) return;
    final confirm = await _promptForPin(l10n.appLockConfirmPinTitle);
    if (confirm != pin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.appLockPinsMismatchMessage)),
        );
      return;
    }

    await ref.read(appLockNotifierProvider).setPin(pin);
  }

  Future<void> _removePin() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.appLockRemoveConfirmTitle,
      message: l10n.appLockRemoveConfirmMessage,
      confirmLabel: l10n.activeWorkoutRemove,
    );
    if (!confirmed) return;
    await ref.read(appLockNotifierProvider).clearPin();
  }

  Future<String?> _promptForPin(String title) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.routineNameDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.appLockOkAction),
          ),
        ],
      ),
    );
  }
}
