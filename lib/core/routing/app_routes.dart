/// Route paths, in one place (F-NAV-002).
///
/// Constants rather than string literals at call sites, because deep links are
/// load-bearing here: home-screen widgets (`F-NAV-007`), app shortcuts
/// (`F-NAV-008`) and rest-timer notification taps (`F-TIM-003`) all route by
/// URI, so a typo is a silently dead entry point rather than a compile error.
///
/// The full map lives in docs/23-NAVIGATION.md. Only the routes Phase 0 needs
/// are defined; the rest arrive with the features that own them.
abstract final class AppRoutes {
  // Shell branches.
  static const String home = '/';
  static const String routines = '/routines';

  /// `/routines/:routineId`.
  static String routine(String routineId) => '$routines/$routineId';

  /// `/routines/:routineId/days/:dayId`.
  static String routineDay(String routineId, String dayId) =>
      '${routine(routineId)}/days/$dayId';

  /// `F-ROU-015` — the built-in program gallery, reached from the routine
  /// list's empty state or app bar.
  static const String starterPrograms = '$routines/starter-programs';

  /// First run only (`F-SET-011`). A real route rather than a dialog over the
  /// dashboard: it is the whole screen until it is dismissed, and `go`ing away
  /// from it must not leave it underneath.
  static const String onboarding = '/onboarding';

  static const String start = '/start';
  static const String history = '/history';
  static const String insights = '/insights';

  /// `F-ANA-006`.
  static const String consistency = '/insights/consistency';

  /// `F-ANA-007`.
  static const String prTimeline = '/insights/prs';

  /// The session in progress. A **singleton** — at most one workout may exist
  /// with a null `ended_at`, in navigation and in the database (`F-LOG-001`).
  static const String activeWorkout = '/workout/active';

  /// The finish summary (`F-LOG-018`). The workout id travels as `extra`
  /// rather than a path segment: by the time this route is reached the
  /// session has just ended, so it is no longer "the" active workout, but it
  /// is also not a deep-linkable destination on its own.
  static const String activeWorkoutSummary = '/workout/active/summary';

  /// `/history/:workoutId`.
  static String historyWorkout(String workoutId) => '$history/$workoutId';

  /// `/history/:workoutId/edit`.
  static String historyWorkoutEdit(String workoutId) =>
      '$history/$workoutId/edit';

  // Catalogue. Pushed over the shell rather than owning a tab: it is reached
  // from Home now and from the exercise picker once F-LOG-002 lands.
  static const String exercises = '/exercises';
  static const String exerciseNew = '/exercises/new';

  /// `/exercises/:exerciseId` — the per-exercise history screen (`F-ANA-002`).
  static String exerciseDetail(String exerciseId) => '$exercises/$exerciseId';

  /// `/exercises/:exerciseId/edit`.
  static String exerciseEdit(String exerciseId) =>
      '${exerciseDetail(exerciseId)}/edit';

  // Pushed over the shell — low-frequency, so they do not dilute the five tabs.
  static const String settings = '/settings';
  static const String settingsUnits = '/settings/units';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsRestTimer = '/settings/rest-timer';
  static const String settingsData = '/settings/data';

  /// Strong/Hevy CSV import (`F-DAT-005`, `F-DAT-006`, `F-DAT-007`).
  static const String settingsDataImport = '/settings/data/import';

  /// App lock PIN (`F-SET-010`).
  static const String settingsAppLock = '/settings/app-lock';

  /// Bars and the plate inventory (`F-PLT-002`).
  static const String settingsPlates = '/settings/plates';
  static const String settingsAbout = '/settings/about';

  /// Bodyweight log (`F-BOD-001`). Reached from Home, same as settings — body
  /// metrics is a Phase 4 destination, but this one screen of it moved up
  /// with the feature that owns it.
  static const String body = '/body';

  /// Progress photos (`F-BOD-004`).
  static const String bodyPhotos = '/body/photos';
}
