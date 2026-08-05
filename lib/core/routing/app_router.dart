import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/appearance_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/units_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/shell/presentation/placeholder_screen.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Application router (F-NAV-002).
///
/// [StatefulShellRoute.indexedStack] gives each tab its own navigator, so
/// switching tabs preserves scroll position and half-completed forms — the
/// acceptance criterion for `F-NAV-001`. A plain `IndexedStack` in a widget
/// would preserve widget state but lose per-tab navigation history.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.routines,
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Routines',
                  arrivesIn: 'Phase 2',
                  description:
                      'Programs and templates. A routine holds days; a day is '
                      'what you start a workout from.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.start,
                // Becomes a modal sheet in Phase 1, once there is something to
                // start (F-LOG-001). A tab destination until then.
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Start',
                  arrivesIn: 'Phase 1',
                  description:
                      'Start an empty workout, or from a routine day. The '
                      'primary action in the app.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const PlaceholderScreen(
                  title: 'History',
                  arrivesIn: 'Phase 1',
                  description:
                      'Past sessions, newest first, with a calendar heatmap '
                      'once F-ANA-006 lands.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.insights,
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Insights',
                  arrivesIn: 'Phase 3',
                  description:
                      'Estimated 1RM trends, volume, sets per muscle group, '
                      'streaks and PRs.',
                ),
              ),
            ],
          ),
        ],
      ),

      // Pushed over the shell rather than owning a tab: low-frequency screens
      // would dilute the five slots (docs/23-NAVIGATION.md).
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'units',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const UnitsScreen(),
          ),
          GoRoute(
            path: 'appearance',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const AppearanceScreen(),
          ),
          GoRoute(
            path: 'about',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => UnknownRouteScreen(uri: state.uri),
  );
});
