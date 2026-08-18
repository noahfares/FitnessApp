import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/theme_provider.dart';
import '../../../core/l10n/l10n.dart';

/// Settings › Appearance (F-SET-002).
///
/// Light, dark, or follow the system. Applies instantly with no restart.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final dynamicColorEnabled = ref.watch(dynamicColorEnabledProvider);
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsAppearance)),
      body: ListView(
        children: [
          RadioGroup<ThemeMode>(
            groupValue: mode,
            onChanged: (selected) {
              if (selected != null) {
                ref.read(themeModeProvider.notifier).set(selected);
              }
            },
            child: Column(
              children: [
                for (final option in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: option,
                    title: Text(option.label(context.l10n)),
                    subtitle: option == ThemeMode.system
                        ? Text(context.l10n.settingsMatchTheDeviceSetting)
                        : null,
                  ),
              ],
            ),
          ),
          const Divider(),
          SwitchListTile(
            value: dynamicColorEnabled,
            onChanged: (enabled) =>
                ref.read(dynamicColorEnabledProvider.notifier).set(enabled),
            title: Text(context.l10n.settingsDynamicColour),
            subtitle: Text(context.l10n.settingsDynamicColourExplainer),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.settingsColoursInThisTheme,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _Swatch('Completed', colors.success, colors.onSuccess),
                    _Swatch('PR', colors.pr, colors.onPr),
                    _Swatch('Warning', colors.warning, colors.onWarning),
                    _Swatch('Delete', colors.danger, colors.onDanger),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // The subtlest colour in the app, and the one most worth
                // checking on a real phone under gym lighting (F-LOG-004).
                Text(
                  context.l10n.settingsGhostValues,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      context.l10n.settings100Kg8,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      context.l10n.settingsLastTime975Kg,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: colors.ghost),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: foreground),
      ),
    );
  }
}
