import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/platform/health_service.dart';
import '../application/health_providers.dart';
import '../application/health_sync.dart';

/// Settings › Health Connect (`F-HLT-001` §2, `F-HLT-002`).
///
/// Both switches start off, and turning one on asks the platform for
/// permission there and then — in context, at the moment the user has said
/// what they want, never at launch. The screen states exactly what is written
/// and exactly what is not, because "share with Health Connect" means nothing
/// on its own.
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _toggle({required bool read, required bool enabled}) async {
    final service = ref.read(healthServiceProvider);
    Future<void> store(bool value) => read
        ? ref.read(healthReadEnabledProvider.notifier).set(value)
        : ref.read(healthWriteEnabledProvider.notifier).set(value);

    if (!enabled) {
      // Turning it off never touches the platform: revoking access is the
      // OS's own screen, and pretending otherwise would be a lie about what
      // this switch does. It stops this app writing, which is what it says.
      await store(false);
      return;
    }

    setState(() => _busy = true);
    final granted = await service.requestPermissions(read: read);
    await store(granted);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = granted ? null : context.l10n.healthPermissionDenied;
    });
  }

  Future<void> _importBodyweight() async {
    setState(() => _busy = true);
    final now = DateTime.now();
    final result = await importBodyweightFromHealth(
      ref.read(healthServiceProvider),
      ref.read(bodyMeasurementRepositoryProvider),
      from: now.subtract(const Duration(days: 365)),
      to: now,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = context.l10n.healthImportResult(
        result.imported,
        result.skipped,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final write = ref.watch(healthWriteEnabledProvider);
    final read = ref.watch(healthReadEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.healthTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Text(
              context.l10n.healthExplainer,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          SwitchListTile(
            value: write,
            onChanged: _busy
                ? null
                : (value) => unawaited(_toggle(read: false, enabled: value)),
            title: Text(context.l10n.healthWriteWorkouts),
            subtitle: Text(context.l10n.healthWriteWorkoutsExplainer),
          ),
          const Divider(),
          SwitchListTile(
            value: read,
            onChanged: _busy
                ? null
                : (value) => unawaited(_toggle(read: true, enabled: value)),
            title: Text(context.l10n.healthReadBodyweight),
            subtitle: Text(context.l10n.healthReadBodyweightExplainer),
          ),
          if (read)
            ListTile(
              title: Text(context.l10n.healthImportBodyweightNow),
              subtitle: Text(context.l10n.healthImportBodyweightExplainer),
              trailing: const Icon(Icons.download),
              onTap: _busy ? null : () => unawaited(_importBodyweight()),
            ),
          if (_message case final message?)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Text(message, style: theme.textTheme.bodyMedium),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Text(
              context.l10n.healthNeverSentAnywhere,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
