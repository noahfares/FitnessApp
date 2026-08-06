/// How long a rest is, when nobody has said (`F-TIM-005`).
///
/// Pure Dart. Equipment and muscle arrive as their stored **names** rather than
/// as the `Equipment` / `Muscle` enums, which live in `lib/data/db/tables/` and
/// the domain layer may not import (docs/20-ARCHITECTURE.md).
library;

/// The muscles whose main exercises are multi-joint, systemically taxing, and
/// want considerably more rest than a cable curl (`F-TIM-005`).
///
/// A coarse split rather than a per-exercise table on purpose: the answer only
/// has to be *better than one global number*, and anyone who disagrees about a
/// specific lift sets that lift's own default, which then wins.
const Set<String> compoundMuscles = {
  'chest',
  'lats',
  'upperBack',
  'lowerBack',
  'quads',
  'hamstrings',
  'glutes',
  'fullBody',
};

/// The built-in rest for an exercise, in seconds.
///
/// Equipment is the stronger signal of the two: a barbell lift is loaded near
/// maximal far more often than a machine one, whatever it trains.
int builtInRestSeconds({
  required String equipment,
  required String primaryMuscle,
}) {
  final compound = compoundMuscles.contains(primaryMuscle);
  return switch (equipment) {
    'barbell' => compound ? 180 : 120,
    'kettlebell' => compound ? 150 : 90,
    'dumbbell' => compound ? 120 : 90,
    'bodyweight' => compound ? 120 : 60,
    'machine' || 'cable' => compound ? 90 : 60,
    'band' => 60,
    // Includes `other` and anything a newer version has added: 90 s is the
    // middle of the range above, and a wrong-but-sane default beats a crash.
    _ => 90,
  };
}

/// The rest duration to use, most specific setting first (`F-TIM-005`).
///
/// Order: the routine's exercise → the exercise's own default → the global
/// setting → the built-in for this kind of exercise. [routineSeconds] is always
/// null until routines exist (`F-ROU-006`, Phase 2); it is a parameter now so
/// that adding them is a call-site change and not a rewrite of the rule.
///
/// [globalSeconds] is null when the global setting is "automatic", which is
/// what lets the built-in split by exercise type survive — a global default
/// that was always set would make it dead code.
int resolveRestSeconds({
  required String equipment,
  required String primaryMuscle,
  int? routineSeconds,
  int? exerciseSeconds,
  int? globalSeconds,
}) =>
    routineSeconds ??
    exerciseSeconds ??
    globalSeconds ??
    builtInRestSeconds(equipment: equipment, primaryMuscle: primaryMuscle);

/// The durations offered in pickers, in seconds.
///
/// Coarse on purpose: 30-second granularity below three minutes and a minute
/// above it covers how people actually think about rest, and a spinner offering
/// 97 seconds is a worse control, not a more precise one.
const List<int> restDurationChoices = [
  30,
  45,
  60,
  75,
  90,
  105,
  120,
  150,
  180,
  240,
  300,
];

/// `45 s`, `1:30 min`, `3 min` — whichever reads shortest for the value.
///
/// Used by every picker that offers a rest duration, which is why it lives
/// beside the choices rather than in whichever screen needed it first.
String formatRestDuration(int seconds) {
  if (seconds < 60) return '$seconds s';
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  if (rest == 0) return '$minutes min';
  return '$minutes:${rest.toString().padLeft(2, '0')} min';
}
