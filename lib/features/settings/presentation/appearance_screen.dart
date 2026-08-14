import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/theme_provider.dart';

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
      appBar: AppBar(title: const Text('Appearance')),
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
                        ? const Text('Match the device setting')
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
            title: const Text('Dynamic colour'),
            subtitle: const Text(
              'Tint the app from your wallpaper. Android 12+ only — off does '
              "nothing on a phone that doesn't support it.",
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Colours in this theme',
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
                  'Ghost values',
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
                      'last time: 97.5 kg × 8',
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
