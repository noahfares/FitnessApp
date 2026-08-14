import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/application/tracked_measurements_provider.dart';
import 'measurement_labels.dart';

/// Which measurements to track (`F-BOD-002`'s own spec: "users choose which
/// measurements to track — showing all thirteen by default is clutter").
///
/// A plain checklist rather than a settings screen of its own — reached
/// directly from the body screen's app bar, since this is the one setting
/// that screen's own content depends on.
Future<void> showTrackedMeasurementsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const TrackedMeasurementsSheet(),
  );
}

class TrackedMeasurementsSheet extends ConsumerWidget {
  const TrackedMeasurementsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tracked = ref.watch(trackedMeasurementTypesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.bodyMeasurementsToTrackAction,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.bodyTrackedDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final type in trackableMeasurementTypes)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(type.label),
                  value: tracked.contains(type),
                  onChanged: (_) => ref
                      .read(trackedMeasurementTypesProvider.notifier)
                      .toggle(type),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
