/// Shared analytics boundary (`F-ANA-001` §3,
/// docs/40-ANALYTICS-SPEC.md §universal-preconditions rules 2–3).
///
/// Tombstoned rows are already excluded before data reaches `domain/` —
/// `deleted_at IS NULL` is a SQL predicate, applied by the repository, not a
/// Dart one. This is the one check every in-memory metric still has to make
/// for itself: warm-up and incomplete sets are never counted, anywhere.
library;

/// Whether a set with [setType] and [isCompleted] counts towards any metric.
bool isCountedSet({required String setType, required bool isCompleted}) =>
    setType != 'warmup' && isCompleted;

/// Whether [trackingType] contributes to volume load
/// (docs/40-ANALYTICS-SPEC.md §2 rule 1) — other tracking types are excluded
/// entirely, never counted as zero.
bool isVolumeEligible(String trackingType) =>
    trackingType == 'weightReps' || trackingType == 'weightTime';
