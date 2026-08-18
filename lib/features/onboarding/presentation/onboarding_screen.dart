import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/units/distance.dart';
import '../../../core/units/mass.dart';
import '../../../data/db/database_provider.dart';
import '../../../domain/routines/starter_programs.dart';
import '../../settings/application/theme_provider.dart';
import '../../settings/application/unit_preferences_provider.dart';
import '../../shell/widgets/apple_list.dart';
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
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextButton(
                  onPressed: () => unawaited(_finish()),
                  child: Text(
                    context.l10n.onboardingSkip,
                    style: TextStyle(fontSize: 17, color: colors.tint),
                  ),
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page ? colors.tint : colors.labelTertiary,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: SizedBox(
                height: 50,
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
    final mode = ref.watch(themeModeProvider);

    return _Page(
      icon: Icons.fitness_center,
      title: context.l10n.onboardingWelcomeTitle,
      body: context.l10n.onboardingWelcomeBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldLabel(context.l10n.onboardingAppearance),
          const SizedBox(height: AppSpacing.sm),
          SegmentedTrack<ThemeMode>(
            selected: mode,
            segments: [
              (value: ThemeMode.system, label: context.l10n.themeModeSystem),
              (value: ThemeMode.light, label: context.l10n.themeModeLight),
              (value: ThemeMode.dark, label: context.l10n.themeModeDark),
            ],
            onChanged: (value) =>
                unawaited(ref.read(themeModeProvider.notifier).set(value)),
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
          _FieldLabel(context.l10n.onboardingWeightUnit),
          const SizedBox(height: AppSpacing.sm),
          SegmentedTrack<MassUnit>(
            selected: prefs.load,
            segments: [
              for (final unit in MassUnit.values)
                (value: unit, label: unit.symbol),
            ],
            onChanged: (unit) {
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
    final colors = context.appColors;

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
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  onTap: _imported == null && _importing == null
                      ? () => unawaited(_import(program))
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                program.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.17,
                                  color: colors.label,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                program.summary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.labelSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (_imported == program.id)
                          Icon(Icons.check, color: colors.tint)
                        else if (_importing == program.id)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.tint,
                            ),
                          )
                        else
                          Icon(Icons.add, color: colors.tint),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.onboardingProgramLater,
            style: TextStyle(fontSize: 13, color: colors.labelSecondary),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
        color: context.appColors.label,
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
    final colors = context.appColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: colors.tint),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.84,
              height: 1.1,
              color: colors.label,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: TextStyle(fontSize: 16, color: colors.labelSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}
