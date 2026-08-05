import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../settings/application/theme_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';

/// Temporary screen for Phase 0, replaced by the real shell in batch 0.4.
///
/// It exists so the foundation is *visible* rather than only tested: the theme
/// in both schemes, the semantic colours, tabular figures, and live unit
/// switching driving real formatted values. Delete this file when
/// `F-NAV-001` lands.
class FoundationPreview extends ConsumerWidget {
  const FoundationPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final formatter = ref.watch(quantityFormatterProvider);
    final units = ref.watch(unitPreferencesProvider);
    final themeMode = ref.watch(themeModeProvider);

    // The worked fixtures from docs/40-ANALYTICS-SPEC.md, so the numbers on
    // screen are the same ones the tests assert on.
    const topSet = Mass.grams(102500);
    const sessionVolume = Mass.grams(12480000);
    const estimated1rm = Mass.grams(126667);

    return Scaffold(
      appBar: AppBar(title: const Text('Foundation')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text('Phase 0', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Units, formatting and theming. No features yet.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),

          _Section(
            title: 'Appearance',
            child: SegmentedButton<ThemeMode>(
              segments: [
                for (final mode in ThemeMode.values)
                  ButtonSegment(value: mode, label: Text(mode.label)),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) =>
                  ref.read(themeModeProvider.notifier).set(selection.first),
            ),
          ),

          _Section(
            title: 'Load unit',
            child: SegmentedButton<MassUnit>(
              segments: [
                for (final unit in MassUnit.values)
                  ButtonSegment(value: unit, label: Text(unit.symbol)),
              ],
              selected: {units.load},
              onSelectionChanged: (selection) => ref
                  .read(unitPreferencesProvider.notifier)
                  .setLoad(selection.first),
            ),
          ),

          _Section(
            title: 'Formatted values',
            child: Column(
              children: [
                _Row(
                  label: 'Top set',
                  value: formatter.setWeight(topSet, showUnit: true),
                ),
                _Row(
                  label: 'Estimated 1RM',
                  value: formatter.e1rm(estimated1rm),
                ),
                _Row(
                  label: 'Session volume',
                  value: formatter.volume(sessionVolume),
                ),
                _Row(
                  label: 'Bodyweight',
                  value: formatter.bodyweight(const Mass.grams(80000)),
                ),
              ],
            ),
          ),

          _Section(
            title: 'Tabular figures',
            child: Column(
              children: [
                // These must line up vertically. Proportional digits would not.
                for (final grams in [100000, 102500, 60000, 8000])
                  _Row(
                    label: 'Set',
                    value: formatter.setWeight(
                      Mass.grams(grams),
                      showUnit: true,
                    ),
                  ),
              ],
            ),
          ),

          _Section(
            title: 'Semantic colours',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _Swatch('Completed', colors.success, colors.onSuccess),
                _Swatch('PR', colors.pr, colors.onPr),
                _Swatch('Warning', colors.warning, colors.onWarning),
                _Swatch('Delete', colors.danger, colors.onDanger),
              ],
            ),
          ),

          _Section(
            title: 'Ghost value (F-LOG-004)',
            child: Row(
              children: [
                Text('8', style: theme.textTheme.bodyLarge),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'last time: ${formatter.setWeight(topSet, showUnit: true)} × 8',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.ghost,
                  ),
                ),
              ],
            ),
          ),

          _Section(
            title: 'Chart palette',
            child: Row(
              children: [
                for (final colour in colors.chartSeries)
                  Expanded(
                    child: Container(height: AppSpacing.xxl, color: colour),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(value, style: theme.textTheme.bodyLarge),
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
