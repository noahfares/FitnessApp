/// Deload suggestion (`F-PRG-011`).
///
/// Pure Dart. A suggestion with reasoning, never an automatic change to the
/// program — this module only decides whether to say something and what to
/// say; nothing here writes to a routine.
library;

import '../analytics/acwr.dart';
import '../analytics/stall_detection.dart';

class DeloadSuggestion {
  const DeloadSuggestion({required this.suggested, required this.reasons});

  /// True only when **both** signals indicate it — stall detection alone or
  /// workload ratio alone is not enough (`F-PRG-011`'s own spec).
  final bool suggested;

  /// Plain-English reasoning for whichever signals fired. Empty when
  /// [suggested] is false and neither signal is even present.
  final List<String> reasons;
}

/// [sharpRampThreshold] is the ACWR read as "training load has ramped up
/// sharply" (`docs/40-ANALYTICS-SPEC.md` §8 rule 3's ~1.5).
DeloadSuggestion suggestDeload({
  required StallVerdict? stall,
  required AcwrResult? acwr,
  double sharpRampThreshold = 1.5,
}) {
  final stalled = stall?.stalled ?? false;
  final ratio = acwr?.ratio;
  final rampedUp = ratio != null && ratio >= sharpRampThreshold;

  return DeloadSuggestion(
    suggested: stalled && rampedUp,
    reasons: [
      if (stalled) 'Progress has stalled over the trailing window.',
      if (rampedUp)
        'Training load has ramped up sharply this week '
            '(ACWR ${ratio.toStringAsFixed(2)}).',
    ],
  );
}
