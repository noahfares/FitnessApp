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
#    Compares regenerated content against what is on disk. Deliberately NOT a
#    git-diff check: that conflates "stale" with "merely uncommitted" and
#    false-alarms during ordinary work.
if [ -f docs/features.tsv ] && [ -f docs/30-features/INDEX.md ]; then
  _tsv=$(mktemp) _idx=$(mktemp)
  cp docs/features.tsv "$_tsv"; cp docs/30-features/INDEX.md "$_idx"
  python3 tools/gen_index.py >/dev/null 2>&1
  if cmp -s "$_tsv" docs/features.tsv && cmp -s "$_idx" docs/30-features/INDEX.md; then
    ok "features.tsv and INDEX.md current"
  else
    bad "features.tsv/INDEX.md were stale — regenerated in place, include them in your commit"
  fi
  rm -f "$_tsv" "$_idx"
else
  bad "generated index missing — run tools/gen-index.sh"
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

# 8. README states the current version, and states it exactly once
#    (it silently went stale once already — hence the check rather than care)
readme_versions=$(grep -oE '`[0-9]+\.[0-9]+\.[0-9]+`' README.md | tr -d '`' | sort -u)
count=$(printf '%s\n' "$readme_versions" | grep -c . || true)
if [ "$count" -eq 1 ] && [ "$readme_versions" = "$V" ]; then
  ok "README version current (${V})"
elif [ "$count" -gt 1 ]; then
  bad "README names several versions (${readme_versions//$'\n'/, }) — keep exactly one"
else
  bad "README says '${readme_versions:-none}', VERSION says ${V}"
fi

# 9. The About screen states the current version
#    It is the only diagnostic context this app has — no telemetry, no crash
#    reporting — so a stale version there makes bug reports unattributable.
about=lib/features/settings/presentation/about_screen.dart
if [ -f "$about" ]; then
  shown=$(grep -oE "version = '[0-9]+\.[0-9]+\.[0-9]+'" "$about" \
          | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
  if [ "$shown" = "$V" ]; then
    ok "About screen version current (${V})"
  else
    bad "About screen says '${shown:-none}', VERSION says ${V}"
  fi
fi

echo
[ "$fail" -eq 0 ] && echo "All checks passed." || echo "Some checks FAILED."
exit "$fail"
