/// Warm-up set generation (`F-LOG-020`).
///
/// Pure Dart. Rounding to what's actually loadable is the caller's own
/// weight-source-aware logic (`F-PLT-001`/`F-PLT-005`) — this module only
/// knows fractions of a working weight, never a bar or a plate.
library;

import 'dart:convert';

/// One rung of a warm-up ramp: a fraction of the working weight, and how
/// many reps. `percent <= 0` means "the bar" / the minimum load, not a
/// literal zero-weight set.
class WarmupStep {
  const WarmupStep({required this.percent, required this.reps});

  final double percent;
  final int reps;

  Map<String, dynamic> toJson() => {'percent': percent, 'reps': reps};

  factory WarmupStep.fromJson(Map<String, dynamic> json) => WarmupStep(
    percent: (json['percent'] as num).toDouble(),
    reps: json['reps'] as int,
  );

  @override
  bool operator ==(Object other) =>
      other is WarmupStep && other.percent == percent && other.reps == reps;

  @override
  int get hashCode => Object.hash(percent, reps);
}

/// Bar (or minimum) × 8, 40% × 5, 60% × 3, 80% × 1 — a standard ramp into a
/// working set (`F-LOG-020`'s own spec example).
const List<WarmupStep> defaultWarmupRuleset = [
  WarmupStep(percent: 0, reps: 8),
  WarmupStep(percent: 0.4, reps: 5),
  WarmupStep(percent: 0.6, reps: 3),
  WarmupStep(percent: 0.8, reps: 1),
];

class GeneratedWarmupSet {
  const GeneratedWarmupSet({required this.weightGrams, required this.reps});

  final int weightGrams;
  final int reps;
}

/// Generates warm-up sets ramping into [workingWeightGrams].
///
/// Each step's raw target is rounded via [roundToAchievable] — the caller's
/// own weight-source-aware rounding — then clamped to
/// `[minWeightGrams, workingWeightGrams]`: a step never proposes something
/// lighter than what's actually loadable, and never heavier than the
/// working set it's building up to.
List<GeneratedWarmupSet> generateWarmupSets({
  required int workingWeightGrams,
  required int minWeightGrams,
  required int Function(int targetGrams) roundToAchievable,
  List<WarmupStep> ruleset = defaultWarmupRuleset,
}) {
  return [
    for (final step in ruleset)
      GeneratedWarmupSet(
        weightGrams: _clamp(
          roundToAchievable(
            step.percent <= 0
                ? minWeightGrams
                : (workingWeightGrams * step.percent).round(),
          ),
          minWeightGrams,
          workingWeightGrams,
        ),
        reps: step.reps,
      ),
  ];
}

int _clamp(int value, int min, int max) {
  if (max < min) return min; // A working weight lighter than the bar itself.
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

/// Persisted as `exercises.warmup_ruleset` — null uses [defaultWarmupRuleset].
String encodeWarmupRuleset(List<WarmupStep> ruleset) =>
    jsonEncode([for (final s in ruleset) s.toJson()]);

/// Falls back to [defaultWarmupRuleset] for null, empty, or malformed input
/// — a corrupt override must never block generating warm-ups at all.
List<WarmupStep> decodeWarmupRuleset(String? json) {
  if (json == null || json.isEmpty) return defaultWarmupRuleset;
  try {
    final list = jsonDecode(json) as List;
    final steps = [
      for (final entry in list)
        WarmupStep.fromJson(entry as Map<String, dynamic>),
    ];
    return steps.isEmpty ? defaultWarmupRuleset : steps;
  } on FormatException {
    return defaultWarmupRuleset;
  } on TypeError {
    return defaultWarmupRuleset;
  }
}
