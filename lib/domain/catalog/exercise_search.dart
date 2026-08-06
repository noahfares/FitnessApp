/// Catalogue search and filtering (`F-CAT-004`, `F-CAT-005`).
///
/// Pure Dart, per the layer rule in [`CLAUDE.md`](../../../CLAUDE.md): no
/// Flutter, no Drift types. Matching and ordering are exactly the kind of logic
/// that is silently wrong rather than loudly broken — "rdl" quietly failing to
/// find Romanian Deadlift looks like a missing exercise, not a bug — so it
/// lives here under test instead of inside a widget.
library;

/// A catalogue row reduced to what search and filtering need.
///
/// The folded forms are computed once per instance and reused across every
/// keystroke, which is what keeps a 400-row catalogue inside the sub-100 ms
/// budget in `F-CAT-004` without an index.
class ExerciseCandidate {
  ExerciseCandidate({
    required this.id,
    required this.name,
    this.aliases = const <String>[],
    this.primaryMuscle = '',
    this.equipment = '',
    this.isFavorite = false,
    this.lastUsedAt,
  });

  final String id;
  final String name;

  /// Searchable but not displayed — "RDL", "OHP" (`F-CAT-008`).
  final List<String> aliases;

  /// Enum **names**, not the enum types. `Muscle` and `Equipment` are declared
  /// in `lib/data/db/tables/enums.dart`, which this layer may not import.
  final String primaryMuscle;
  final String equipment;

  final bool isFavorite;

  /// Epoch milliseconds of the last session this exercise appeared in, or null
  /// if never used.
  ///
  /// Always null in Phase 1 — there is no history yet. Ordering handles it
  /// anyway because `F-CAT-004` specifies recency as a tiebreak, and wiring it
  /// later is then a one-line change in the provider rather than a change here.
  final int? lastUsedAt;

  late final String foldedName = foldForSearch(name);

  late final List<String> foldedAliases = <String>[
    for (final alias in aliases) foldForSearch(alias),
  ];
}

/// Which facets are selected, plus the current query.
///
/// Immutable and value-equal so a Riverpod provider watching it rebuilds on a
/// real change and not on an identical rebuild.
class ExerciseFilter {
  const ExerciseFilter({
    this.query = '',
    this.muscles = const <String>{},
    this.equipment = const <String>{},
  });

  final String query;

  /// Primary muscle only. Secondary muscles deliberately do not match: a filter
  /// on "biceps" that returns every row is not a filter.
  final Set<String> muscles;

  final Set<String> equipment;

  /// **AND across categories, OR within one** (`F-CAT-005`). Barbell + machine
  /// with chest selected means "a chest exercise that uses either".
  bool acceptsFacets(ExerciseCandidate candidate) =>
      (muscles.isEmpty || muscles.contains(candidate.primaryMuscle)) &&
      (equipment.isEmpty || equipment.contains(candidate.equipment));

  bool get hasFacets => muscles.isNotEmpty || equipment.isNotEmpty;

  bool get hasQuery => foldForSearch(query).isNotEmpty;

  bool get isActive => hasFacets || hasQuery;

  int get facetCount => muscles.length + equipment.length;

  ExerciseFilter copyWith({
    String? query,
    Set<String>? muscles,
    Set<String>? equipment,
  }) => ExerciseFilter(
    query: query ?? this.query,
    muscles: muscles ?? this.muscles,
    equipment: equipment ?? this.equipment,
  );

  ExerciseFilter toggleMuscle(String muscle) =>
      copyWith(muscles: _toggled(muscles, muscle));

  ExerciseFilter toggleEquipment(String item) =>
      copyWith(equipment: _toggled(equipment, item));

  /// Clears the chips but keeps what was typed — clearing filters and losing
  /// the search text mid-session is the annoying version of this.
  ExerciseFilter get withoutFacets => ExerciseFilter(query: query);

  static Set<String> _toggled(Set<String> current, String value) {
    final next = Set<String>.of(current);
    if (!next.remove(value)) next.add(value);
    return next;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseFilter &&
          other.query == query &&
          _sameSet(other.muscles, muscles) &&
          _sameSet(other.equipment, equipment);

  @override
  int get hashCode => Object.hash(
    query,
    Object.hashAllUnordered(muscles),
    Object.hashAllUnordered(equipment),
  );

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

/// Applies [filter] to [candidates] and returns them in display order.
///
/// Ordering (`F-CAT-004` §3): exact prefix match, then favourites, then
/// recency, then alphabetical. Id is the final tiebreak so the order is total
/// and the list never reshuffles between identical rebuilds.
List<ExerciseCandidate> searchExercises(
  Iterable<ExerciseCandidate> candidates,
  ExerciseFilter filter,
) {
  final query = foldForSearch(filter.query);
  final tokens = query.isEmpty ? const <String>[] : query.split(' ');

  final matched = <ExerciseCandidate>[];
  for (final candidate in candidates) {
    if (!filter.acceptsFacets(candidate)) continue;
    if (tokens.isNotEmpty && !_matchesEveryToken(candidate, tokens)) continue;
    matched.add(candidate);
  }

  final ranks = <String, int>{
    for (final candidate in matched) candidate.id: _rank(candidate, query),
  };

  matched.sort((a, b) {
    final byRank = ranks[a.id]!.compareTo(ranks[b.id]!);
    if (byRank != 0) return byRank;
    if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
    final byRecency = _compareRecency(a.lastUsedAt, b.lastUsedAt);
    if (byRecency != 0) return byRecency;
    final byName = a.foldedName.compareTo(b.foldedName);
    if (byName != 0) return byName;
    return a.id.compareTo(b.id);
  });

  return matched;
}

/// Every token must appear somewhere, so "inc bench" finds "Incline Bench
/// Press" (`F-CAT-004` §4). Tokens are unordered: "bench inc" works too, which
/// matters because that is what typing fast and correcting yourself produces.
bool _matchesEveryToken(ExerciseCandidate candidate, List<String> tokens) {
  for (final token in tokens) {
    if (candidate.foldedName.contains(token)) continue;
    if (candidate.foldedAliases.any((alias) => alias.contains(token))) continue;
    return false;
  }
  return true;
}

/// Lower is better. Whole-query prefix beats a mid-word hit, so typing "row"
/// surfaces "Row" and "Rowing" above "Narrow Grip Bench Press".
int _rank(ExerciseCandidate candidate, String query) {
  if (query.isEmpty) return 0;
  final name = candidate.foldedName;
  if (name == query) return 0;
  if (name.startsWith(query)) return 1;
  if (_anyWordStartsWith(name, query)) return 2;
  if (candidate.foldedAliases.any((alias) => alias.startsWith(query))) return 3;
  return 4;
}

bool _anyWordStartsWith(String haystack, String prefix) {
  for (final word in haystack.split(' ')) {
    if (word.startsWith(prefix)) return true;
  }
  return false;
}

/// Most recently used first; never-used rows sort last rather than first.
int _compareRecency(int? a, int? b) {
  if (a == b) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}

/// Lower-cases, strips diacritics, and collapses whitespace.
///
/// Both sides of every comparison go through this, so "Bíceps" matches
/// "biceps" and a stray leading space is not a zero-result search
/// (`F-CAT-004` §1, §4).
String foldForSearch(String input) {
  final buffer = StringBuffer();
  var pendingSpace = false;

  for (final rune in input.toLowerCase().runes) {
    if (_isWhitespace(rune)) {
      // Deferred rather than written, so trailing whitespace never survives.
      if (buffer.isNotEmpty) pendingSpace = true;
      continue;
    }
    if (pendingSpace) {
      buffer.write(' ');
      pendingSpace = false;
    }
    final char = String.fromCharCode(rune);
    buffer.write(_diacritics[char] ?? char);
  }

  return buffer.toString();
}

bool _isWhitespace(int rune) =>
    rune == 0x20 || rune == 0x09 || rune == 0x0A || rune == 0x0D || rune == 0xA0;

/// Latin-1 Supplement and Latin Extended-A, folded to ASCII.
///
/// A table rather than Unicode normalisation because Dart's core library has no
/// NFD decomposition, and pulling a package in for 90 entries would put a
/// dependency underneath the domain layer.
const Map<String, String> _diacritics = <String, String>{
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a',
  'ă': 'a', 'ą': 'a',
  'ç': 'c', 'ć': 'c', 'ĉ': 'c', 'ċ': 'c', 'č': 'c',
  'ð': 'd', 'ď': 'd', 'đ': 'd',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ĕ': 'e', 'ė': 'e',
  'ę': 'e', 'ě': 'e',
  'ĝ': 'g', 'ğ': 'g', 'ġ': 'g', 'ģ': 'g',
  'ĥ': 'h', 'ħ': 'h',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ĩ': 'i', 'ī': 'i', 'ĭ': 'i',
  'į': 'i', 'ı': 'i',
  'ĵ': 'j',
  'ķ': 'k',
  'ĺ': 'l', 'ļ': 'l', 'ľ': 'l', 'ł': 'l',
  'ñ': 'n', 'ń': 'n', 'ņ': 'n', 'ň': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'ō': 'o',
  'ŏ': 'o', 'ő': 'o',
  'ŕ': 'r', 'ŗ': 'r', 'ř': 'r',
  'ś': 's', 'ŝ': 's', 'ş': 's', 'š': 's',
  'ţ': 't', 'ť': 't', 'ŧ': 't',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ũ': 'u', 'ū': 'u', 'ŭ': 'u',
  'ů': 'u', 'ű': 'u', 'ų': 'u',
  'ŵ': 'w',
  'ý': 'y', 'ÿ': 'y', 'ŷ': 'y',
  'ź': 'z', 'ż': 'z', 'ž': 'z',
  // Ligatures and eszett expand rather than map one-to-one.
  'æ': 'ae', 'œ': 'oe', 'ß': 'ss',
};
