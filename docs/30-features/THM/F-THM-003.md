# F-THM-003 — Dynamic colour

Status: done | Priority: P2 | Phase: 2
Reads: 24-DESIGN-SYSTEM

## Spec

Android 12+ wallpaper-derived colour, user-toggleable, **off by default** so the
app has a consistent identity out of the box. Must not break the semantic roles —
`pr` and `danger` keep their meaning regardless of the wallpaper.

## Status notes

Uses the `dynamic_color` package (a platform channel only, no network call —
first new dependency since `F-DAT-011`'s `share_plus`). `AppTheme.light`/
`.dark` now take an optional `dynamicScheme`, harmonized against it via the
package's own `ColorScheme.harmonized()` (shifts `error` and friends toward
the dynamic `primary` so a wallpaper extreme can't produce a clashing error
colour) rather than used raw. `AppColors` — the `pr`/`danger`/`success`/
`warning` semantic roles — was already a fixed `ThemeExtension` never
derived from `ColorScheme` (its own doc comment anticipated this feature by
name), so "must not break the semantic roles" holds by construction; a test
pins it rather than trusting the comment. `dynamicColorEnabledProvider`
persists the toggle, off by default, on Settings › Appearance.
`DynamicColorBuilder` wraps the app root and supplies null schemes on any
platform or OS version the package doesn't support, which is exactly the
existing "off" fallback — no platform branching needed anywhere else.
