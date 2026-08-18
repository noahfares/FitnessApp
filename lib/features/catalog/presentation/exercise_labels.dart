/// Human-readable names for the catalogue enums.
///
/// Display only, and deliberately not stored: the database keeps enum *names*
/// so a raw dump stays readable (`F-DAT-011`). These become the localisation
/// surface in `F-I18N-001`; until then, English literals match the rest of the
/// app.
library;

import '../../../data/db/tables/enums.dart';
import '../../../l10n/app_localizations.dart';

extension MuscleLabel on Muscle {
  String label(AppLocalizations l10n) => switch (this) {
    Muscle.chest => l10n.muscleChest,
    Muscle.frontDelts => l10n.muscleFrontDelts,
    Muscle.sideDelts => l10n.muscleSideDelts,
    Muscle.rearDelts => l10n.muscleRearDelts,
    Muscle.lats => l10n.muscleLats,
    Muscle.traps => l10n.muscleTraps,
    Muscle.upperBack => l10n.muscleUpperBack,
    Muscle.lowerBack => l10n.muscleLowerBack,
    Muscle.biceps => l10n.muscleBiceps,
    Muscle.triceps => l10n.muscleTriceps,
    Muscle.forearms => l10n.muscleForearms,
    Muscle.quads => l10n.muscleQuads,
    Muscle.hamstrings => l10n.muscleHamstrings,
    Muscle.glutes => l10n.muscleGlutes,
    Muscle.calves => l10n.muscleCalves,
    Muscle.adductors => l10n.muscleAdductors,
    Muscle.abductors => l10n.muscleAbductors,
    Muscle.abs => l10n.muscleAbs,
    Muscle.obliques => l10n.muscleObliques,
    Muscle.neck => l10n.muscleNeck,
    Muscle.fullBody => l10n.muscleFullBody,
  };
}

extension EquipmentLabel on Equipment {
  String label(AppLocalizations l10n) => switch (this) {
    Equipment.barbell => l10n.equipmentBarbell,
    Equipment.dumbbell => l10n.equipmentDumbbell,
    Equipment.machine => l10n.equipmentMachine,
    Equipment.cable => l10n.equipmentCable,
    Equipment.bodyweight => l10n.equipmentBodyweight,
    Equipment.band => l10n.equipmentBand,
    Equipment.kettlebell => l10n.equipmentKettlebell,
    Equipment.other => l10n.equipmentOther,
  };
}

extension TrackingTypeLabel on TrackingType {
  String label(AppLocalizations l10n) => switch (this) {
    TrackingType.weightReps => l10n.trackingWeightReps,
    TrackingType.bodyweightReps => l10n.trackingBodyweightReps,
    TrackingType.reps => l10n.trackingReps,
    TrackingType.time => l10n.trackingTime,
    TrackingType.distanceTime => l10n.trackingDistanceTime,
    TrackingType.weightTime => l10n.trackingWeightTime,
  };
}
