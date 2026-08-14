import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/theme_provider.dart';

/// Settings › Appearance (F-SET-002).
///
/// Light, dark, or follow the system. Applies instantly with no restart.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mode = ref.watch(themeModeProvider);
    final dynamicColorEnabled = ref.watch(dynamicColorEnabledProvider);
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceTitle)),
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
                    title: Text(option.label),
                    subtitle: option == ThemeMode.system
                        ? Text(l10n.appearanceMatchDeviceSetting)
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
            title: Text(l10n.appearanceDynamicColorLabel),
            subtitle: Text(l10n.appearanceDynamicColorDescription),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appearanceColoursHeading,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _Swatch(
                      l10n.appearanceSwatchCompleted,
                      colors.success,
                      colors.onSuccess,
                    ),
                    _Swatch(l10n.appearanceSwatchPr, colors.pr, colors.onPr),
                    _Swatch(
                      l10n.appearanceSwatchWarning,
                      colors.warning,
                      colors.onWarning,
                    ),
                    _Swatch(
                      l10n.routinesDeleteAction,
                      colors.danger,
                      colors.onDanger,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // The subtlest colour in the app, and the one most worth
                // checking on a real phone under gym lighting (F-LOG-004).
                Text(
                  l10n.appearanceGhostValuesHeading,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                // `Wrap`, not `Row`: at large text scales the two strings
                // together are wider than a phone screen, and a `Row` would
                // overflow rather than drop the ghost value to its own line
                // (F-A11Y-002).
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.md,
                  children: [
                    Text(
                      '100 kg × 8',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      l10n.appearanceGhostValueLabel('97.5 kg × 8'),
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
