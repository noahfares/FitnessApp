import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/catalog/presentation/exercise_catalog_screen.dart';
import '../../features/catalog/presentation/exercise_editor_screen.dart';
import '../../features/history/presentation/edit_past_workout_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/workout_detail_screen.dart';
import '../../features/logging/application/active_workout_providers.dart';
import '../../features/logging/presentation/active_workout_screen.dart';
import '../../features/logging/presentation/session_summary_screen.dart';
import '../../features/logging/presentation/start_workout_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/appearance_screen.dart';
import '../../features/settings/presentation/rest_timer_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/units_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/shell/presentation/dashboard_screen.dart';
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
    // Resolved before the first frame from whether a session is in progress
    // (`F-LOG-007` §2). Reopening after a kill lands *in* the workout, with no
    // "restore session?" prompt and no flash of the dashboard first.
    initialLocation: ref.watch(startupLocationProvider),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const DashboardScreen(),
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
                // Tapping the centre tab opens this as a modal sheet
                // (docs/23-NAVIGATION.md); the route itself stays so a deep
                // link or app shortcut lands on a real screen.
                builder: (context, state) => const StartWorkoutScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
                routes: [
                  // Pushed over the root navigator, not the History branch's
                  // own — a detail view belongs in the app-wide stack, the
                  // same way exercise detail does (docs/23-NAVIGATION.md).
                  GoRoute(
                    path: ':workoutId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => WorkoutDetailScreen(
                      workoutId: state.pathParameters['workoutId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => EditPastWorkoutScreen(
                          workoutId: state.pathParameters['workoutId']!,
                        ),
                      ),
                    ],
                  ),
                ],
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

      // Over the shell, not inside a branch: a session is not a tab, and
      // leaving it must never mean losing it.
      GoRoute(
        path: AppRoutes.activeWorkout,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ActiveWorkoutScreen(),
      ),

      GoRoute(
        path: AppRoutes.activeWorkoutSummary,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            SessionSummaryScreen(workoutId: state.extra! as String),
      ),

      GoRoute(
        path: AppRoutes.exercises,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExerciseCatalogScreen(),
        routes: [
          // Declared before `:exerciseId`, which would otherwise swallow it —
          // go_router matches in declaration order.
          GoRoute(
            path: 'new',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const ExerciseEditorScreen(),
          ),
          GoRoute(
            path: ':exerciseId/edit',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => ExerciseEditorScreen(
              exerciseId: state.pathParameters['exerciseId'],
            ),
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
            path: 'rest-timer',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const RestTimerScreen(),
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
