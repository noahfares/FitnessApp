/// Human-readable names for the catalogue enums.
///
/// Display only, and deliberately not stored: the database keeps enum *names*
/// so a raw dump stays readable (`F-DAT-011`). These become the localisation
/// surface in `F-I18N-001`; until then, English literals match the rest of the
/// app.
library;

import '../../../data/db/tables/enums.dart';

extension MuscleLabel on Muscle {
  String get label => switch (this) {
    Muscle.chest => 'Chest',
    Muscle.frontDelts => 'Front delts',
    Muscle.sideDelts => 'Side delts',
    Muscle.rearDelts => 'Rear delts',
    Muscle.lats => 'Lats',
    Muscle.traps => 'Traps',
    Muscle.upperBack => 'Upper back',
    Muscle.lowerBack => 'Lower back',
    Muscle.biceps => 'Biceps',
    Muscle.triceps => 'Triceps',
    Muscle.forearms => 'Forearms',
    Muscle.quads => 'Quads',
    Muscle.hamstrings => 'Hamstrings',
    Muscle.glutes => 'Glutes',
    Muscle.calves => 'Calves',
    Muscle.adductors => 'Adductors',
    Muscle.abductors => 'Abductors',
    Muscle.abs => 'Abs',
    Muscle.obliques => 'Obliques',
    Muscle.neck => 'Neck',
    Muscle.fullBody => 'Full body',
  };
}

extension EquipmentLabel on Equipment {
  String get label => switch (this) {
    Equipment.barbell => 'Barbell',
    Equipment.dumbbell => 'Dumbbell',
    Equipment.machine => 'Machine',
    Equipment.cable => 'Cable',
    Equipment.bodyweight => 'Bodyweight',
    Equipment.band => 'Band',
    Equipment.kettlebell => 'Kettlebell',
    Equipment.other => 'Other',
  };
}

extension TrackingTypeLabel on TrackingType {
  String get label => switch (this) {
    TrackingType.weightReps => 'Weight × reps',
    TrackingType.bodyweightReps => 'Bodyweight reps',
    TrackingType.reps => 'Reps only',
    TrackingType.time => 'Time',
    TrackingType.distanceTime => 'Distance & time',
    TrackingType.weightTime => 'Weight & time',
  };
}
