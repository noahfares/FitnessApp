#!/usr/bin/env bash
# Scaffold a new feature entry with the next free ID in a domain.
#
#   tools/new-feature.sh LOG "Undo across sessions"
#
# Creates docs/30-features/LOG/F-LOG-0NN.md from the standard template and
# regenerates the index. Fill in the entry, then commit — remembering the
# version bump and tag (docs/63-VERSIONING.md).
set -euo pipefail
cd "$(dirname "$0")/.."

DOM="${1:?usage: new-feature.sh <DOMAIN> \"<title>\"}"
TITLE="${2:?usage: new-feature.sh <DOMAIN> \"<title>\"}"
DIR="docs/30-features/${DOM}"

[ -d "$DIR" ] || { echo "unknown domain '${DOM}' — see docs/00-INDEX.md"; exit 1; }

last=$(ls "$DIR"/F-"${DOM}"-*.md 2>/dev/null | sed 's/.*-\([0-9]\{3\}\)\.md/\1/' \
       | sort -n | tail -1)
next=$(printf '%03d' $((10#${last:-0} + 1)))
ID="F-${DOM}-${next}"
FILE="${DIR}/${ID}.md"

# Inherit the domain's usual Reads: from a sibling, so the default is sensible
reads=$(grep -h '^Reads:' "$DIR"/F-*.md 2>/dev/null | sort | uniq -c \
        | sort -rn | head -1 | sed 's/^ *[0-9]* *Reads: *//')

cat > "$FILE" <<EOF
# ${ID} — ${TITLE}

Status: idea | Priority: P2 | Phase: —
Reads: ${reads:-21-DATA-MODEL}

## Spec

1. TODO

## Acceptance

- [ ] TODO

## Edge cases

TODO

## Open questions

TODO

---

## Why

TODO — why this exists and what it's worth. Skipped when implementing.
EOF

./tools/gen-index.sh >/dev/null
echo "created ${FILE}"
echo
echo "Next:"
echo "  1. Fill in the entry (drop any section that genuinely doesn't apply)."
echo "  2. If scheduling it, add ${ID} to a phase in docs/50-ROADMAP.md and set Phase:."
echo "  3. Otherwise add it to docs/51-BACKLOG.md."
echo "  4. tools/check-docs.sh, then commit with a version bump and tag."
