#!/usr/bin/env bash
# Documentation integrity check. Run after any planning session.
#
#   tools/check-docs.sh
#
# Verifies: no orphan feature-ID references, no orphan Reads: targets,
# features.tsv is in sync, roadmap IDs all exist, VERSION agrees with
# pubspec.yaml (once it exists), and the ID count reconciles.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
note() { printf '  %s\n' "$*"; }
ok()   { printf '\033[32mPASS\033[0m  %s\n' "$1"; }
bad()  { printf '\033[31mFAIL\033[0m  %s\n' "$1"; fail=1; }

# 1. Every feature file is well formed and its filename matches its heading
mismatch=$(for f in docs/30-features/*/F-*.md; do
  id=$(basename "$f" .md)
  head -1 "$f" | grep -q "^# ${id} — " || echo "$f"
done)
[ -z "$mismatch" ] && ok "feature files well formed" \
  || { bad "filename/heading mismatch"; note "$mismatch"; }

# 2. No orphan ID references anywhere in docs/
grep -rhoE '^# (F-[A-Z0-9]+-[0-9]{3})' docs/30-features/*/F-*.md \
  | sed 's/^# //' | sort -u > /tmp/_defined
grep -rhoE 'F-[A-Z0-9]+-[0-9]{3}' docs/ CLAUDE.md README.md 2>/dev/null \
  | sort -u > /tmp/_referenced
orphans=$(comm -13 /tmp/_defined /tmp/_referenced)
[ -z "$orphans" ] && ok "no orphan ID references" \
  || { bad "referenced but never defined"; note "$orphans"; }

# 3. Every Reads: target resolves to a real file
badreads=$(grep -h '^Reads:' docs/30-features/*/F-*.md \
  | sed 's/^Reads: *//' | tr ',' '\n' | sed 's/^ *//; s/ *$//; s/#.*//' \
  | grep -v '^$' | sort -u | while read -r t; do
      [ -e "docs/${t}.md" ] || [ -e "docs/${t}" ] || echo "$t"
    done)
[ -z "$badreads" ] && ok "all Reads: targets resolve" \
  || { bad "unresolvable Reads: targets"; note "$badreads"; }

# 4. features.tsv in sync with the feature files
if [ -f docs/features.tsv ]; then
  python3 tools/gen_index.py >/dev/null 2>&1
  if git diff --quiet -- docs/features.tsv docs/30-features/INDEX.md 2>/dev/null; then
    ok "features.tsv and INDEX.md current"
  else
    bad "features.tsv/INDEX.md stale — regenerated, commit the result"
  fi
else
  bad "docs/features.tsv missing — run tools/gen-index.sh"
fi

# 5. Every ID scheduled in the roadmap exists
roadmap_orphans=$(grep -oE 'F-[A-Z0-9]+-[0-9]{3}' docs/50-ROADMAP.md \
  | sort -u | comm -13 /tmp/_defined -)
[ -z "$roadmap_orphans" ] && ok "roadmap IDs all defined" \
  || { bad "roadmap references undefined IDs"; note "$roadmap_orphans"; }

# 6. Phase counts reconcile
defined=$(wc -l < /tmp/_defined)
scheduled=$(grep -h '^Status:' docs/30-features/*/F-*.md | grep -vc 'Phase: —')
backlog=$(grep -h '^Status:' docs/30-features/*/F-*.md | grep -c 'Phase: —')
if [ "$((scheduled + backlog))" -eq "$defined" ]; then
  ok "counts reconcile — ${defined} defined, ${scheduled} scheduled, ${backlog} backlog"
else
  bad "count mismatch: ${defined} defined vs ${scheduled}+${backlog}"
fi

# 7. VERSION agrees with pubspec.yaml (once Flutter exists)
V=$(tr -d '[:space:]' < VERSION)
if [ -f pubspec.yaml ]; then
  grep -q "^version: ${V}" pubspec.yaml \
    && ok "VERSION matches pubspec.yaml (${V})" \
    || bad "VERSION=${V} does not match pubspec.yaml"
else
  ok "VERSION=${V} (no pubspec.yaml yet)"
fi

echo
[ "$fail" -eq 0 ] && echo "All checks passed." || echo "Some checks FAILED."
exit "$fail"
