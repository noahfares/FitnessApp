import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../logging/presentation/start_workout_screen.dart';
import '../widgets/active_workout_banner.dart';

/// The five-tab shell (F-NAV-001).
///
/// Reachability drives the layout: the app is used one-handed, standing,
/// mid-set, so navigation and primary actions live in the bottom half of the
/// screen where a thumb reaches without shifting grip (docs/23-NAVIGATION.md).
///
/// Settings and body metrics are reached from Home rather than owning a tab —
/// they are low-frequency and would dilute the five slots.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// The five bottom-navigation slots, localized — a function rather than a
  /// compile-time constant, since a label can't be resolved from
  /// [AppLocalizations] without a [BuildContext]. Public because tests
  /// assert against it, the same reason the destinations themselves were
  /// public before this became a function.
  static List<ShellDestination> destinationsFor(AppLocalizations l10n) => [
    ShellDestination(l10n.shellHomeLabel, Icons.home_outlined, Icons.home),
    ShellDestination(
      l10n.routinesTitle,
      Icons.list_alt_outlined,
      Icons.list_alt,
    ),
    // The centre slot is the primary action, deliberately unmissable.
    ShellDestination(
      l10n.startWorkoutTitle,
      Icons.add_circle_outline,
      Icons.add_circle,
    ),
    ShellDestination(
      l10n.historyTitle,
      Icons.calendar_month_outlined,
      Icons.calendar_month,
    ),
    ShellDestination(
      l10n.insightsTitle,
      Icons.insights_outlined,
      Icons.insights,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = destinationsFor(l10n);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Directly above the bar on every shell screen, never inside a tab
          // (`F-NAV-003`) — it must survive switching tabs, not just scrolling.
          const ActiveWorkoutBanner(),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) =>
                _onDestinationSelected(context, index),
            destinations: [
              for (final destination in destinations)
                NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                  tooltip: destination.label,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// The index of the centre Start slot.
  static const int startIndex = 2;

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == startIndex) {
      // A sheet, not a branch switch: it preserves whatever is behind it and
      // lands the interaction in the thumb zone (docs/23-NAVIGATION.md). The
      // /start route still exists for deep links.
      unawaited(showStartWorkoutSheet(context));
      return;
    }
    // initialLocation: true on re-tapping the current tab pops it back to its
    // root — the behaviour people expect, and the cheapest way out of a deep
    // stack when a rest timer is running.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// One bottom-navigation slot. Public because [AppShell.destinations] is, and
/// tests assert against it.
class ShellDestination {
  const ShellDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
