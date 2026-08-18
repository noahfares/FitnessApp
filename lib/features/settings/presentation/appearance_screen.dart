import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shell/widgets/apple_list.dart';
import '../../shell/widgets/section_header.dart';
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
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(context.l10n.settingsAppearance)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          AppleListSection(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SegmentedTrack<ThemeMode>(
                  selected: mode,
                  segments: [
                    for (final option in ThemeMode.values)
                      (value: option, label: option.label(context.l10n)),
                  ],
                  onChanged: (selected) =>
                      ref.read(themeModeProvider.notifier).set(selected),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              context.l10n.settingsMatchTheDeviceSetting,
              style: TextStyle(fontSize: 13, color: colors.labelSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppleListSection(
            children: [
              AppleSwitchRow(
                title: context.l10n.settingsDynamicColour,
                subtitle: context.l10n.settingsDynamicColourExplainer,
                value: dynamicColorEnabled,
                onChanged: (enabled) =>
                    ref.read(dynamicColorEnabledProvider.notifier).set(enabled),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(context.l10n.settingsColoursInThisTheme),
          const SizedBox(height: AppSpacing.sm),
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
          // The subtlest colour in the app, and the one most worth checking on
          // a real phone under gym lighting (F-LOG-004).
          Text(
            context.l10n.settingsGhostValues,
            style: TextStyle(fontSize: 13, color: colors.labelSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                context.l10n.settings100Kg8,
                style: TextStyle(fontSize: 17, color: colors.label),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                context.l10n.settingsLastTime975Kg,
                style: TextStyle(fontSize: 17, color: colors.ghost),
              ),
            ],
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
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Text(label, style: TextStyle(fontSize: 13, color: foreground)),
    );
  }
}
