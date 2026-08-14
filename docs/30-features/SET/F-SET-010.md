# F-SET-010 — App lock

Status: done | Priority: P3 | Phase: 5
Depends on: F-BOD-004
Reads: 22-UNITS

## Spec

Optional biometric or PIN lock. Matters mainly because of progress photos and
body measurements, which are the most sensitive data the app holds.

---

## Status note (batch 5.4)

PIN only — off by default, configured from Settings › App lock
(`AppLockScreen`). `PinHasher` (`core/security/pin_hasher.dart`) stores a
salted SHA-256 hash via `SharedPreferences`, never the PIN itself, and
generates a fresh random salt on every `setPin`. `AppLockGate` wraps
`MaterialApp.router`'s `builder`, is a genuine no-op with no PIN configured
(the default every existing widget test that pumps `FitnessApp` relies on,
verified by re-running the full widget suite after adding the gate rather
than assumed), and re-locks on every return from the background via
`WidgetsBindingObserver`, not just on cold start. Biometric unlock is **not
built**: `local_auth` needs platform manifest/entitlement work (Android
`USE_BIOMETRIC` permission, iOS `NSFaceIDUsageDescription`) this session's
toolchain — no Android SDK, no physical device — can't responsibly add
without verifying it, the same class of deferral as `F-TIM-003`'s
background notification. Also explicitly **not** encryption at rest: this
gates casual access to the running app, nothing more. `PinHasher`'s own doc
comment says so directly, and so does the in-app copy on `AppLockScreen`,
so a PIN's protection isn't overstated to whoever reads either.
