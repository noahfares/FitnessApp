import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/platform/health_connect_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/health_connect_settings_provider.dart';

/// Settings › Health Connect (`F-HLT-001`, `F-HLT-002`).
///
/// One toggle gates both directions: while off, nothing is written and
/// nothing is read, regardless of whatever permission Health Connect itself
/// still remembers granting from an earlier session.
class HealthConnectSettingsScreen extends ConsumerWidget {
  const HealthConnectSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final enabled = ref.watch(healthConnectEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsHealthConnectTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            l10n.healthConnectWriteDescription,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.healthConnectReadDescription,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.healthConnectEnableLabel),
            value: enabled,
            onChanged: (value) => unawaited(_setEnabled(context, ref, value)),
          ),
          if (enabled) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => unawaited(_revoke(context, ref)),
              child: Text(l10n.healthConnectRevokeAction),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _setEnabled(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final notifier = ref.read(healthConnectEnabledProvider.notifier);
    if (!value) {
      await notifier.setEnabled(enabled: false);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(healthConnectServiceProvider);
    if (!await service.isAvailable()) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.healthConnectUnavailableMessage)),
        );
      return;
    }

    final granted = await service.requestPermissions();
    if (!granted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.healthConnectPermissionDeniedMessage)),
        );
      return;
    }

    await notifier.setEnabled(enabled: true);
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    await ref.read(healthConnectServiceProvider).revokePermissions();
    await ref
        .read(healthConnectEnabledProvider.notifier)
        .setEnabled(enabled: false);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.healthConnectRevokedMessage)));
  }
}
