/// The build-time source version — what the JSON dump stamps itself with
/// (`F-DAT-011`) and the loading/error fallback for About's version line.
///
/// Kept in step with `VERSION` and `pubspec.yaml` by `tools/check-docs.sh`.
/// The version actually shown in About comes from the installed package at
/// runtime instead (`F-REL-005`, `lib/data/platform/app_info_service.dart`),
/// since that is the one that can disagree with this constant if a build
/// mislabels itself — this constant can't detect that on its own.
const String appVersion = '0.48.5';
