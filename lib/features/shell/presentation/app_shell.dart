import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../logging/presentation/start_workout_screen.dart';

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

  static const List<ShellDestination> destinations = [
    ShellDestination('Home', Icons.home_outlined, Icons.home),
    ShellDestination('Routines', Icons.list_alt_outlined, Icons.list_alt),
    // The centre slot is the primary action, deliberately unmissable.
    ShellDestination('Start', Icons.add_circle_outline, Icons.add_circle),
    ShellDestination(
      'History',
      Icons.calendar_month_outlined,
      Icons.calendar_month,
    ),
    ShellDestination('Insights', Icons.insights_outlined, Icons.insights),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
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
