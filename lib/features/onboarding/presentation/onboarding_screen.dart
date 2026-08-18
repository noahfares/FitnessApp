import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/distance.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/database_provider.dart';
import '../../../domain/routines/starter_programs.dart';
import '../../settings/application/theme_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../application/onboarding_provider.dart';

/// First run (`F-SET-011`).
///
/// Three questions, all of which already have a sensible default, and a Skip
/// on every one of them — which is why skipping is a complete answer rather
/// than a postponement (§2): it leaves the app exactly as it would have been
/// without this screen.
///
/// What is deliberately absent is the point of the feature (§3): no account,
/// no email capture, no permission prompts, no "allow notifications to get the
/// most out of…". The strongest first impression this app can make is asking
/// for nothing.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _next() {
    if (_page == _pages - 1) {
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
    final theme = Theme.of(context);

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
                  child: Text(context.l10n.onboardingSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: const [
                  _WelcomePage(),
                  _UnitsPage(),
                  _StarterProgramPage(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    _page == _pages - 1
                        ? context.l10n.onboardingStartTraining
                        : context.l10n.onboardingNext,
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

class _WelcomePage extends ConsumerWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);

    return _Page(
      icon: Icons.fitness_center,
      title: context.l10n.onboardingWelcomeTitle,
      body: context.l10n.onboardingWelcomeBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.onboardingAppearance,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(context.l10n.themeModeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(context.l10n.themeModeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(context.l10n.themeModeDark),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) => unawaited(
              ref.read(themeModeProvider.notifier).set(selection.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitsPage extends ConsumerWidget {
  const _UnitsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs = ref.watch(unitPreferencesProvider);
    final notifier = ref.read(unitPreferencesProvider.notifier);

    return _Page(
      icon: Icons.straighten,
      title: context.l10n.onboardingUnitsTitle,
      // The reassurance matters more than the choice: nothing stored is ever
      // rewritten by it (ADR-0003), so getting it "wrong" here costs nothing.
      body: context.l10n.onboardingUnitsBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.onboardingWeightUnit,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<MassUnit>(
            segments: [
              for (final unit in MassUnit.values)
                ButtonSegment(value: unit, label: Text(unit.symbol)),
            ],
            selected: {prefs.load},
            onSelectionChanged: (selection) {
              final unit = selection.first;
              // Bodyweight follows the load unit here rather than asking a
              // fourth question — anyone who wants them to differ can say so
              // on Settings › Units, where that choice already lives.
              unawaited(notifier.setLoad(unit));
              unawaited(notifier.setBody(unit));
              unawaited(
                notifier.setDistance(
                  unit == MassUnit.kg ? DistanceUnit.km : DistanceUnit.miles,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StarterProgramPage extends ConsumerStatefulWidget {
  const _StarterProgramPage();

  @override
  ConsumerState<_StarterProgramPage> createState() =>
      _StarterProgramPageState();
}

class _StarterProgramPageState extends ConsumerState<_StarterProgramPage> {
  String? _importing;
  String? _imported;

  Future<void> _import(StarterProgram program) async {
    setState(() => _importing = program.id);
    await ref.read(routineRepositoryProvider).importStarterProgram(program);
    if (!mounted) return;
    setState(() {
      _importing = null;
      _imported = program.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Page(
      icon: Icons.list_alt,
      title: context.l10n.onboardingProgramTitle,
      body: context.l10n.onboardingProgramBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The first three only: a wall of six programs is a decision, and
          // this screen exists to avoid making one feel necessary. The rest
          // are one tap away in the gallery (`F-ROU-015`), for someone who
          // already knows what they want.
          for (final program in starterPrograms.take(3))
            Card(
              child: ListTile(
                title: Text(program.name),
                subtitle: Text(
                  program.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: _imported == program.id
                    ? const Icon(Icons.check)
                    : _importing == program.id
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                onTap: _imported == null && _importing == null
                    ? () => unawaited(_import(program))
                    : null,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.onboardingProgramLater,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.icon,
    required this.title,
    required this.body,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}
