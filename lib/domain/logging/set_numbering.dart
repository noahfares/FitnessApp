/// Set numbering and type indicators (`F-LOG-005` §2–§3).
///
/// Pure Dart; set types arrive as their stored names for the same reason as in
/// `set_fields.dart`.
library;

/// What the set-number cell shows for one row.
class SetLabel {
  const SetLabel(this.text, {this.badge});

  /// `W1`, `W2` for warm-ups; `1`, `2`, `3` for everything that counts.
  final String text;

  /// A single letter for set types that count but are not plain working sets —
  /// `D`rop, `F`ailure, `A`MRAP, `B`ack-off. Null for warm-up and working,
  /// whose numbering already says which they are.
  final String? badge;

  bool get isWarmup => text.startsWith('W');

  @override
  bool operator ==(Object other) =>
      other is SetLabel && other.text == text && other.badge == badge;

  @override
  int get hashCode => Object.hash(text, badge);

  @override
  String toString() => badge == null ? text : '$text$badge';
}

/// Numbers [setTypes] in row order.
///
/// **Warm-ups are numbered separately** (`F-LOG-005` §3): they are excluded
/// from every analytic, so counting them in the same sequence as working sets
/// would make the row numbers disagree with every figure derived from them —
/// "5 sets" in the summary against a row labelled 7.
List<SetLabel> labelSets(List<String> setTypes) {
  var warmups = 0;
  var counted = 0;
  return [
    for (final type in setTypes)
      if (type == 'warmup')
        SetLabel('W${++warmups}')
      else
        SetLabel('${++counted}', badge: _badgeFor(type)),
  ];
}

String? _badgeFor(String setType) => switch (setType) {
  'drop' => 'D',
  'failure' => 'F',
  'amrap' => 'A',
  'backoff' => 'B',
  _ => null,
};
