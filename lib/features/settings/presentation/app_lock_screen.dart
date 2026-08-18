import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../application/app_lock_provider.dart';
import '../../../core/l10n/l10n.dart';

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
    final hasLock = ref.watch(hasAppLockProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsAppLock)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.settingsAppLockExplainer,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => unawaited(_setOrChangePin(hasLock)),
              child: Text(
                hasLock
                    ? context.l10n.settingsChangePin
                    : context.l10n.settingsSetAPin,
              ),
            ),
            if (hasLock) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => unawaited(_removePin()),
                child: Text(context.l10n.settingsRemovePin),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _setOrChangePin(bool hasExisting) async {
    if (hasExisting) {
      final current = await _promptForPin(
        context.l10n.settingsEnterTheCurrentPin,
      );
      if (current == null) return;
      final valid = ref.read(appLockNotifierProvider).verify(current);
      if (!valid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(context.l10n.settingsWrongPin)),
          );
        return;
      }
    }

    if (!mounted) return;
    final pin = await _promptForPin(context.l10n.settingsChooseAPin4Or);
    if (pin == null || pin.length < 4) return;
    if (!mounted) return;
    final confirm = await _promptForPin(context.l10n.settingsConfirmTheNewPin);
    if (confirm != pin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("PINs didn't match.")));
      return;
    }

    await ref.read(appLockNotifierProvider).setPin(pin);
  }

  Future<void> _removePin() async {
    final confirmed = await showConfirmSheet(
      context,
      title: context.l10n.settingsRemoveAppLock,
      message: context.l10n.settingsTheAppWillOpenWithout,
      confirmLabel: context.l10n.historyRemove,
    );
    if (!confirmed) return;
    await ref.read(appLockNotifierProvider).clearPin();
  }

  Future<String?> _promptForPin(String title) {
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
            child: Text(context.l10n.catalogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(context.l10n.settingsOk),
          ),
        ],
      ),
    );
  }
}
