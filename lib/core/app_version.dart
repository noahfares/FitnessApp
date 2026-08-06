/// The running app's version — the single source every screen and export
/// reads from.
///
/// Kept in step with `VERSION` and `pubspec.yaml` by `tools/check-docs.sh`.
/// Read from the package at runtime once `F-REL-005` wires the build number
/// through; a constant is honest for now and cheaper than a plugin.
const String appVersion = '0.16.0';
