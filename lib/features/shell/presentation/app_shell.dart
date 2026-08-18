import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
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
    final colors = context.appColors;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Directly above the bar on every shell screen, never inside a tab
          // (`F-NAV-003`) — it must survive switching tabs, not just scrolling.
          const ActiveWorkoutBanner(),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.background,
              border: Border(top: BorderSide(color: colors.separator)),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(context, index),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: 10,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: states.contains(WidgetState.selected)
                      ? colors.tint
                      : colors.labelSecondary,
                ),
              ),
              destinations: [
                for (var i = 0; i < destinations.length; i++)
                  if (i == startIndex)
                    NavigationDestination(
                      icon: _StartTabIcon(color: colors.tint),
                      label: '',
                      tooltip: destinations[i].label,
                    )
                  else
                    NavigationDestination(
                      icon: Icon(
                        destinations[i].icon,
                        color: colors.labelSecondary,
                      ),
                      selectedIcon: Icon(
                        destinations[i].selectedIcon,
                        color: colors.tint,
                      ),
                      label: destinations[i].label,
                      tooltip: destinations[i].label,
                    ),
              ],
            ),
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

/// The centre Start slot: a floating filled circle rather than an outline
/// icon, the deliberate emphasis `docs/23-NAVIGATION.md` asks for. No visible
/// label — `Semantics` below carries "Start" for assistive tech instead.
class _StartTabIcon extends StatelessWidget {
  const _StartTabIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Start',
      button: true,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
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
