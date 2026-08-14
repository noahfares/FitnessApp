import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/database_provider.dart';
import '../../../domain/routines/starter_programs.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/application/theme_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../application/onboarding_provider.dart';

/// First-run onboarding (`F-SET-011`).
///
/// Three pages — units and theme, then an optional starter routine — behind
/// a `Skip` that's visible from every one of them. §2's "every choice
/// changeable later" holds by construction: this screen reads and writes the
/// exact same providers Settings does, so nothing chosen here is a separate,
/// onboarding-only value. §3's "no account, no email, no permission prompts"
/// needs no code to satisfy — none of that exists anywhere in this screen.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  static const _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingCompletedProvider.notifier).complete();
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _finishInto(String routineId) async {
    await ref.read(onboardingCompletedProvider.notifier).complete();
    if (mounted) context.go(AppRoutes.routine(routineId));
  }

  void _next() {
    if (_page >= _pageCount - 1) {
      unawaited(_finish());
      return;
    }
    unawaited(
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextButton(
                  onPressed: () => unawaited(_finish()),
                  child: Text(l10n.importSkipAction),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  const _WelcomePage(),
                  const _UnitsAndThemePage(),
                  _StarterRoutinePage(onImported: _finishInto),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pageCount; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: i == _page
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.screen,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    _page >= _pageCount - 1
                        ? l10n.onboardingGetStartedAction
                        : l10n.onboardingContinueAction,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // `SingleChildScrollView`, not a bare centred `Column`: at large text
    // scales the icon plus three text blocks are taller than the page, and
    // a fixed `Column` would overflow rather than let it scroll
    // (F-A11Y-002).
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.onboardingWelcomeTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.onboardingWelcomeTagline, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.onboardingPrivacyNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitsAndThemePage extends ConsumerWidget {
  const _UnitsAndThemePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final units = ref.watch(unitPreferencesProvider);
    final mode = ref.watch(themeModeProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        Text(
          l10n.onboardingMakeItYoursTitle,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.onboardingMakeItYoursSubtitle,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.onboardingWeightUnitLabel,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<MassUnit>(
          segments: [
            for (final unit in MassUnit.values)
              ButtonSegment(value: unit, label: Text(unit.symbol)),
          ],
          selected: {units.load},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => ref
              .read(unitPreferencesProvider.notifier)
              .setLoad(selection.first),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.onboardingThemeLabel, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<ThemeMode>(
          segments: [
            for (final option in ThemeMode.values)
              ButtonSegment(value: option, label: Text(option.label)),
          ],
          selected: {mode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              ref.read(themeModeProvider.notifier).set(selection.first),
        ),
      ],
    );
  }
}

class _StarterRoutinePage extends ConsumerWidget {
  const _StarterRoutinePage({required this.onImported});

  final void Function(String routineId) onImported;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        Text(l10n.onboardingStarterTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.onboardingStarterSubtitle, style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.lg),
        for (final program in starterPrograms)
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              title: Text(program.name),
              subtitle: Text(program.summary),
              trailing: FilledButton.tonal(
                onPressed: () async {
                  final result = await ref
                      .read(routineRepositoryProvider)
                      .importStarterProgram(program);
                  onImported(result.routineId);
                },
                child: Text(l10n.onboardingUseThisAction),
              ),
            ),
          ),
      ],
    );
  }
}
