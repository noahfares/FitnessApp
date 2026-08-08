# F-ANA-002 — Per-exercise history

Status: done | Priority: P0 | Phase: 3
Reads: 40-ANALYTICS-SPEC, 21-DATA-MODEL#sets
Screens: Exercise Detail

## Spec

Reverse-chronological list of every session containing an exercise, each showing
all sets, the best set, session volume, and estimated 1RM. The most-visited
analytics screen — it's what you check before you load the bar.

## Status notes (batch 3.1)

`domain/analytics/exercise_history.dart` (`ExerciseHistorySession` — best set
by e1RM, volume, every set) over `SetRepository.watchExerciseHistory`, a
newest-first join across `sets`/`workout_exercises`/`workouts` scoped to one
exercise (mirrors the existing ghost-values query's shape). `ExerciseDetailScreen`
at `/exercises/:exerciseId`, reached from a new history icon on each catalogue
row — the row's own tap still opens the editor unchanged, so this is an
addition, not a repurposing of existing navigation. No date range yet
(`F-ANA-015`, batch 3.2) — every session shows, which is fine at today's data
volumes and will need revisiting once real history is long.
