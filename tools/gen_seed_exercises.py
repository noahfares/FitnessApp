#!/usr/bin/env python3
"""Generate assets/seed/exercises.json (F-CAT-001).

The catalogue is hand-authored — see assets/seed/SOURCES.md for why. This
script exists so the JSON is reproducible and diffable rather than edited by
hand, where a typo in a muscle name would silently corrupt every
sets-per-muscle figure (F-ANA-005).

    tools/gen_seed_exercises.py

UUIDs are derived deterministically from the external_id, so regenerating never
changes an existing row's identity and therefore never orphans logged sets.
"""
import json
import pathlib
import uuid

# Stable namespace. Never change this: every seeded exercise's UUID derives
# from it, and changing it would re-identify the entire catalogue.
NAMESPACE = uuid.UUID("6f1d8c9e-4b2a-4f3d-9c7e-1a2b3c4d5e6f")

OUT = pathlib.Path("assets/seed/exercises.json")
SEED_VERSION = 1

# (external_id, name, primary, [secondary], equipment, tracking, [aliases])
#
# Tracking type is weightReps unless stated. Muscle names must match the Muscle
# enum in lib/data/db/tables/enums.dart exactly.
E = [
    # ---- Chest -----------------------------------------------------------
    ("barbell-bench-press", "Bench Press", "chest", ["triceps", "frontDelts"], "barbell", None, ["flat bench", "bp"]),
    ("incline-barbell-bench-press", "Incline Bench Press", "chest", ["frontDelts", "triceps"], "barbell", None, []),
    ("decline-barbell-bench-press", "Decline Bench Press", "chest", ["triceps"], "barbell", None, []),
    ("dumbbell-bench-press", "Dumbbell Bench Press", "chest", ["triceps", "frontDelts"], "dumbbell", None, ["db press"]),
    ("incline-dumbbell-press", "Incline Dumbbell Press", "chest", ["frontDelts", "triceps"], "dumbbell", None, []),
    ("machine-chest-press", "Machine Chest Press", "chest", ["triceps", "frontDelts"], "machine", None, []),
    ("cable-fly", "Cable Fly", "chest", ["frontDelts"], "cable", None, ["cable crossover"]),
    ("dumbbell-fly", "Dumbbell Fly", "chest", ["frontDelts"], "dumbbell", None, []),
    ("pec-deck", "Pec Deck", "chest", ["frontDelts"], "machine", None, ["machine fly"]),
    ("push-up", "Push-Up", "chest", ["triceps", "frontDelts"], "bodyweight", "bodyweightReps", ["press-up"]),
    ("chest-dip", "Chest Dip", "chest", ["triceps", "frontDelts"], "bodyweight", "bodyweightReps", []),

    # ---- Back ------------------------------------------------------------
    ("conventional-deadlift", "Deadlift", "lowerBack", ["glutes", "hamstrings", "traps", "lats"], "barbell", None, ["conventional deadlift"]),
    ("sumo-deadlift", "Sumo Deadlift", "glutes", ["quads", "lowerBack", "traps"], "barbell", None, []),
    ("barbell-row", "Barbell Row", "lats", ["upperBack", "biceps", "lowerBack"], "barbell", None, ["bent over row", "bor"]),
    ("pendlay-row", "Pendlay Row", "lats", ["upperBack", "biceps"], "barbell", None, []),
    ("dumbbell-row", "Dumbbell Row", "lats", ["upperBack", "biceps"], "dumbbell", None, ["one arm row"]),
    ("seated-cable-row", "Seated Cable Row", "lats", ["upperBack", "biceps"], "cable", None, []),
    ("chest-supported-row", "Chest Supported Row", "upperBack", ["lats", "biceps"], "machine", None, []),
    ("t-bar-row", "T-Bar Row", "lats", ["upperBack", "biceps"], "barbell", None, []),
    ("lat-pulldown", "Lat Pulldown", "lats", ["biceps", "upperBack"], "cable", None, ["pulldown"]),
    ("pull-up", "Pull-Up", "lats", ["biceps", "upperBack"], "bodyweight", "bodyweightReps", []),
    ("chin-up", "Chin-Up", "lats", ["biceps"], "bodyweight", "bodyweightReps", []),
    ("straight-arm-pulldown", "Straight-Arm Pulldown", "lats", [], "cable", None, []),
    ("barbell-shrug", "Barbell Shrug", "traps", ["forearms"], "barbell", None, []),
    ("dumbbell-shrug", "Dumbbell Shrug", "traps", ["forearms"], "dumbbell", None, []),
    ("back-extension", "Back Extension", "lowerBack", ["glutes", "hamstrings"], "bodyweight", "bodyweightReps", ["hyperextension"]),
    ("rack-pull", "Rack Pull", "lowerBack", ["traps", "lats", "glutes"], "barbell", None, []),

    # ---- Shoulders -------------------------------------------------------
    ("overhead-press", "Overhead Press", "frontDelts", ["triceps", "sideDelts"], "barbell", None, ["ohp", "military press", "strict press"]),
    ("seated-dumbbell-press", "Seated Dumbbell Press", "frontDelts", ["triceps", "sideDelts"], "dumbbell", None, []),
    ("machine-shoulder-press", "Machine Shoulder Press", "frontDelts", ["triceps", "sideDelts"], "machine", None, []),
    ("lateral-raise", "Lateral Raise", "sideDelts", [], "dumbbell", None, ["side raise", "lat raise"]),
    ("cable-lateral-raise", "Cable Lateral Raise", "sideDelts", [], "cable", None, []),
    ("rear-delt-fly", "Rear Delt Fly", "rearDelts", ["upperBack"], "dumbbell", None, ["reverse fly"]),
    ("face-pull", "Face Pull", "rearDelts", ["upperBack", "traps"], "cable", None, []),
    ("front-raise", "Front Raise", "frontDelts", [], "dumbbell", None, []),
    ("upright-row", "Upright Row", "sideDelts", ["traps", "biceps"], "barbell", None, []),
    ("arnold-press", "Arnold Press", "frontDelts", ["sideDelts", "triceps"], "dumbbell", None, []),

    # ---- Legs ------------------------------------------------------------
    ("back-squat", "Back Squat", "quads", ["glutes", "lowerBack", "hamstrings"], "barbell", None, ["squat", "high bar squat"]),
    ("front-squat", "Front Squat", "quads", ["glutes", "upperBack"], "barbell", None, []),
    ("low-bar-squat", "Low Bar Squat", "quads", ["glutes", "lowerBack", "hamstrings"], "barbell", None, []),
    ("hack-squat", "Hack Squat", "quads", ["glutes"], "machine", None, []),
    ("leg-press", "Leg Press", "quads", ["glutes", "hamstrings"], "machine", None, []),
    ("bulgarian-split-squat", "Bulgarian Split Squat", "quads", ["glutes", "hamstrings"], "dumbbell", None, ["bss", "rear foot elevated split squat"]),
    ("walking-lunge", "Walking Lunge", "quads", ["glutes", "hamstrings"], "dumbbell", None, ["lunge"]),
    ("goblet-squat", "Goblet Squat", "quads", ["glutes"], "dumbbell", None, []),
    ("step-up", "Step-Up", "quads", ["glutes"], "dumbbell", None, []),
    ("leg-extension", "Leg Extension", "quads", [], "machine", None, []),
    ("romanian-deadlift", "Romanian Deadlift", "hamstrings", ["glutes", "lowerBack"], "barbell", None, ["rdl"]),
    ("stiff-leg-deadlift", "Stiff-Leg Deadlift", "hamstrings", ["glutes", "lowerBack"], "barbell", None, ["sldl"]),
    ("lying-leg-curl", "Lying Leg Curl", "hamstrings", ["calves"], "machine", None, ["hamstring curl"]),
    ("seated-leg-curl", "Seated Leg Curl", "hamstrings", ["calves"], "machine", None, []),
    ("nordic-curl", "Nordic Curl", "hamstrings", ["glutes"], "bodyweight", "bodyweightReps", []),
    ("hip-thrust", "Hip Thrust", "glutes", ["hamstrings"], "barbell", None, []),
    ("glute-bridge", "Glute Bridge", "glutes", ["hamstrings"], "barbell", None, []),
    ("cable-pull-through", "Cable Pull-Through", "glutes", ["hamstrings"], "cable", None, []),
    ("standing-calf-raise", "Standing Calf Raise", "calves", [], "machine", None, []),
    ("seated-calf-raise", "Seated Calf Raise", "calves", [], "machine", None, []),
    ("hip-abduction", "Hip Abduction", "abductors", ["glutes"], "machine", None, []),
    ("hip-adduction", "Hip Adduction", "adductors", [], "machine", None, []),

    # ---- Arms ------------------------------------------------------------
    ("barbell-curl", "Barbell Curl", "biceps", ["forearms"], "barbell", None, []),
    ("dumbbell-curl", "Dumbbell Curl", "biceps", ["forearms"], "dumbbell", None, []),
    ("hammer-curl", "Hammer Curl", "biceps", ["forearms"], "dumbbell", None, []),
    ("incline-dumbbell-curl", "Incline Dumbbell Curl", "biceps", ["forearms"], "dumbbell", None, []),
    ("preacher-curl", "Preacher Curl", "biceps", ["forearms"], "barbell", None, []),
    ("cable-curl", "Cable Curl", "biceps", ["forearms"], "cable", None, []),
    ("concentration-curl", "Concentration Curl", "biceps", [], "dumbbell", None, []),
    ("triceps-pushdown", "Triceps Pushdown", "triceps", [], "cable", None, ["pushdown", "cable pushdown"]),
    ("rope-pushdown", "Rope Pushdown", "triceps", [], "cable", None, []),
    ("skull-crusher", "Skull Crusher", "triceps", [], "barbell", None, ["lying triceps extension"]),
    ("overhead-triceps-extension", "Overhead Triceps Extension", "triceps", [], "dumbbell", None, []),
    ("close-grip-bench-press", "Close-Grip Bench Press", "triceps", ["chest", "frontDelts"], "barbell", None, ["cgbp"]),
    ("triceps-dip", "Triceps Dip", "triceps", ["chest", "frontDelts"], "bodyweight", "bodyweightReps", []),
    ("wrist-curl", "Wrist Curl", "forearms", [], "barbell", None, []),
    ("farmers-walk", "Farmer's Walk", "forearms", ["traps", "abs"], "dumbbell", "weightTime", ["farmers carry"]),

    # ---- Core ------------------------------------------------------------
    ("plank", "Plank", "abs", ["obliques"], "bodyweight", "time", []),
    ("side-plank", "Side Plank", "obliques", ["abs"], "bodyweight", "time", []),
    ("hanging-leg-raise", "Hanging Leg Raise", "abs", ["obliques", "forearms"], "bodyweight", "bodyweightReps", []),
    ("cable-crunch", "Cable Crunch", "abs", [], "cable", None, []),
    ("crunch", "Crunch", "abs", [], "bodyweight", "bodyweightReps", ["sit-up"]),
    ("ab-wheel-rollout", "Ab Wheel Rollout", "abs", ["obliques", "lats"], "bodyweight", "bodyweightReps", []),
    ("russian-twist", "Russian Twist", "obliques", ["abs"], "bodyweight", "bodyweightReps", []),
    ("dead-bug", "Dead Bug", "abs", [], "bodyweight", "bodyweightReps", []),
    ("pallof-press", "Pallof Press", "obliques", ["abs"], "cable", None, []),

    # ---- Olympic / full body --------------------------------------------
    ("power-clean", "Power Clean", "fullBody", ["traps", "quads", "glutes"], "barbell", None, []),
    ("hang-clean", "Hang Clean", "fullBody", ["traps", "quads"], "barbell", None, []),
    ("push-press", "Push Press", "frontDelts", ["triceps", "quads"], "barbell", None, []),
    ("snatch", "Snatch", "fullBody", ["traps", "quads", "glutes"], "barbell", None, []),
    ("kettlebell-swing", "Kettlebell Swing", "glutes", ["hamstrings", "lowerBack"], "kettlebell", None, []),
    ("thruster", "Thruster", "fullBody", ["quads", "frontDelts"], "barbell", None, []),
    ("burpee", "Burpee", "fullBody", ["chest", "quads"], "bodyweight", "bodyweightReps", []),

    # ---- Neck ------------------------------------------------------------
    ("neck-curl", "Neck Curl", "neck", [], "other", None, []),
    ("neck-extension", "Neck Extension", "neck", [], "other", None, []),

    # ---- Cardio ----------------------------------------------------------
    ("treadmill-run", "Treadmill Run", "fullBody", ["quads", "calves"], "machine", "distanceTime", ["run"]),
    ("outdoor-run", "Outdoor Run", "fullBody", ["quads", "calves"], "bodyweight", "distanceTime", []),
    ("stationary-bike", "Stationary Bike", "quads", ["calves", "glutes"], "machine", "distanceTime", ["cycling"]),
    ("rowing-machine", "Rowing Machine", "fullBody", ["lats", "quads"], "machine", "distanceTime", ["erg", "rower"]),
    ("elliptical", "Elliptical", "fullBody", ["quads"], "machine", "distanceTime", []),
    ("stair-climber", "Stair Climber", "quads", ["glutes", "calves"], "machine", "time", ["stairmaster"]),
    ("jump-rope", "Jump Rope", "calves", ["fullBody"], "other", "time", ["skipping"]),
    ("incline-walk", "Incline Walk", "quads", ["glutes", "calves"], "machine", "distanceTime", []),
]

VALID_MUSCLES = {
    "chest", "frontDelts", "sideDelts", "rearDelts", "lats", "traps",
    "upperBack", "lowerBack", "biceps", "triceps", "forearms", "quads",
    "hamstrings", "glutes", "calves", "adductors", "abductors", "abs",
    "obliques", "neck", "fullBody",
}
VALID_EQUIPMENT = {
    "barbell", "dumbbell", "machine", "cable", "bodyweight", "band",
    "kettlebell", "other",
}
VALID_TRACKING = {
    "weightReps", "bodyweightReps", "reps", "time", "distanceTime", "weightTime",
}


def main() -> int:
    seen_ids, seen_names, records = set(), set(), []

    for ext_id, name, primary, secondary, equipment, tracking, aliases in E:
        tracking = tracking or "weightReps"

        assert ext_id not in seen_ids, f"duplicate external_id {ext_id}"
        assert name not in seen_names, f"duplicate name {name}"
        assert primary in VALID_MUSCLES, f"{ext_id}: bad primary {primary}"
        assert equipment in VALID_EQUIPMENT, f"{ext_id}: bad equipment {equipment}"
        assert tracking in VALID_TRACKING, f"{ext_id}: bad tracking {tracking}"
        for m in secondary:
            assert m in VALID_MUSCLES, f"{ext_id}: bad secondary {m}"
            assert m != primary, f"{ext_id}: {m} listed as both primary and secondary"
        seen_ids.add(ext_id)
        seen_names.add(name)

        records.append({
            "uuid": str(uuid.uuid5(NAMESPACE, ext_id)),
            "externalId": ext_id,
            "name": name,
            "primaryMuscle": primary,
            "secondaryMuscles": secondary,
            "equipment": equipment,
            "trackingType": tracking,
            "aliases": aliases,
        })

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(
        {"seedVersion": SEED_VERSION, "exercises": records},
        indent=2,
        ensure_ascii=False,
    ) + "\n")

    by_muscle: dict[str, int] = {}
    for r in records:
        by_muscle[r["primaryMuscle"]] = by_muscle.get(r["primaryMuscle"], 0) + 1
    print(f"wrote {OUT} — {len(records)} exercises")
    print("  by primary muscle:", dict(sorted(by_muscle.items())))
    uncovered = VALID_MUSCLES - set(by_muscle)
    if uncovered:
        print("  NOTE: no exercise targets:", sorted(uncovered))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
