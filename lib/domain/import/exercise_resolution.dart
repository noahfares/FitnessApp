/// What `F-DAT-007`'s mapping screen decides for one unmatched exercise
/// name: map it to an existing catalogue exercise, create a new custom one,
/// or skip every set logged against it.
enum ExerciseResolutionKind { useExisting, createCustom, skip }

class ExerciseResolution {
  const ExerciseResolution.useExisting(String id)
    : kind = ExerciseResolutionKind.useExisting,
      exerciseId = id;
  const ExerciseResolution.createCustom()
    : kind = ExerciseResolutionKind.createCustom,
      exerciseId = null;
  const ExerciseResolution.skip()
    : kind = ExerciseResolutionKind.skip,
      exerciseId = null;

  final ExerciseResolutionKind kind;
  final String? exerciseId;
}
