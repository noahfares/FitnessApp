# F-THM-006 — App icon and branding

Status: done | Priority: P2 | Phase: 6
Reads: 24-DESIGN-SYSTEM

Icon, adaptive icon, splash, and store assets. Deferred until there's something
worth putting an icon on, but required before any public listing (`F-REL-006`).

---

## Accessibility — `A11Y`

Built in continuously, not retrofitted in Phase 6. Each item below is part of the
definition of done for every feature ([`../60-ENGINEERING.md`](../../60-ENGINEERING.md)),
with a dedicated audit pass in Phase 6.

## Implementation

- `tools/gen-icons.sh` generates every icon from one script rather than
  checking in binaries nobody can edit without a design tool: five launcher
  densities, five adaptive-icon foregrounds, the 512×512 store icon and the
  1024×500 feature graphic. Change the shapes or the colour, re-run, and all
  twelve follow — which is the only way five sizes of the same icon stay the
  same icon.
- The mark is original: a barbell built from rounded rectangles, plates
  stepping down in height from the middle out so it still reads as a barbell at
  48 px. No font dependency, nothing traced.
- PNG encoding is hand-rolled (zlib plus four chunks) so the tooling needs no
  Pillow in a repository whose only Python is `tools/`.
- Adaptive icon: flat `@color/ic_launcher_background` behind a foreground drawn
  inside the 66% safe zone, plus a `<monochrome>` layer so Android 13's themed
  icons work. The launch window uses the same colour and mark, so starting the
  app reads as this app starting rather than as a white flash — in dark mode
  too.
- The manifest label was still `fitness_app`; it is `FitnessApp` now.
- The brand colour is `AppTheme.seed` in three places by necessity (Dart, the
  icon script, `colors.xml`); the script names itself as the source and the XML
  comment says where else to change it.
