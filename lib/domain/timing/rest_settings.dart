/// The rest-timer preferences (`F-SET-003`, `F-TIM-006`).
///
/// Pure Dart value type, like `UnitPreferences`: the notifier that persists it
/// lives in `lib/features/settings/`, and the platform code that acts on
/// [RestAlertStyle] lives in `lib/data/platform/`. Neither rule belongs to
/// either of those.
library;

/// How the end of a rest announces itself (`F-TIM-006`).
///
/// [silent] still shows the notification — it means "no sound and no buzz", not
/// "no alert at all". Someone training in a quiet gym wants the first, and
/// nobody wants the second.
enum RestAlertStyle { silent, sound, vibration, both }

extension RestAlertStyleLabel on RestAlertStyle {
  String get label => switch (this) {
    RestAlertStyle.silent => 'Silent',
    RestAlertStyle.sound => 'Sound',
    RestAlertStyle.vibration => 'Vibration',
    RestAlertStyle.both => 'Sound and vibration',
  };

  bool get playsSound =>
      this == RestAlertStyle.sound || this == RestAlertStyle.both;

  bool get vibrates =>
      this == RestAlertStyle.vibration || this == RestAlertStyle.both;
}

/// The pre-warning is a fixed 10 s or off (`F-TIM-006`). Anything finer is a
/// setting nobody tunes and everybody has to read past.
const int restPreWarningSeconds = 10;

class RestTimerSettings {
  const RestTimerSettings({
    this.autoStart = true,
    this.defaultSeconds,
    this.alertStyle = RestAlertStyle.both,
    this.preWarning = false,
  });

  /// Completing a set starts the timer (`F-TIM-002` §1). On by default: the
  /// whole point of the feature is not having to remember to press anything
  /// between sets.
  final bool autoStart;

  /// The global default rest, or null for "automatic" — resolved per exercise
  /// by `builtInRestSeconds` (`F-TIM-005`).
  final int? defaultSeconds;

  final RestAlertStyle alertStyle;

  /// A quieter alert [restPreWarningSeconds] before zero, so the bar can be
  /// reached before it goes off.
  final bool preWarning;

  RestTimerSettings copyWith({
    bool? autoStart,
    int? defaultSeconds,
    bool clearDefaultSeconds = false,
    RestAlertStyle? alertStyle,
    bool? preWarning,
  }) => RestTimerSettings(
    autoStart: autoStart ?? this.autoStart,
    defaultSeconds: clearDefaultSeconds
        ? null
        : (defaultSeconds ?? this.defaultSeconds),
    alertStyle: alertStyle ?? this.alertStyle,
    preWarning: preWarning ?? this.preWarning,
  );

  @override
  bool operator ==(Object other) =>
      other is RestTimerSettings &&
      other.autoStart == autoStart &&
      other.defaultSeconds == defaultSeconds &&
      other.alertStyle == alertStyle &&
      other.preWarning == preWarning;

  @override
  int get hashCode =>
      Object.hash(autoStart, defaultSeconds, alertStyle, preWarning);
}
