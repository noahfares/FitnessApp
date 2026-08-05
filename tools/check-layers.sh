#!/usr/bin/env bash
# Enforce the central architectural invariant (docs/20-ARCHITECTURE.md):
#
#   lib/domain/ imports nothing from Flutter and nothing from lib/data/.
#
# All maths that can be silently wrong lives in lib/domain/ as pure Dart, so it
# is exhaustively testable. A wrong number in a chart is worse than a missing
# chart, because you would act on it.
#
# This runs in CI (F-REL-001). It is a required check, not advice.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0

if [ ! -d lib/domain ]; then
  echo "lib/domain/ does not exist yet — nothing to check."
  exit 0
fi

# Flutter imports
flutter_hits=$(grep -rnE "^\s*import\s+'package:flutter(_[a-z_]+)?/" lib/domain/ || true)
if [ -n "$flutter_hits" ]; then
  echo "FAIL  lib/domain/ imports Flutter:"
  printf '%s\n' "$flutter_hits" | sed 's/^/      /'
  fail=1
fi

# Data-layer imports, both package: and relative
data_hits=$(grep -rnE "^\s*import\s+'(package:[a-z_]+/data/|(\.\./)+data/)" lib/domain/ || true)
if [ -n "$data_hits" ]; then
  echo "FAIL  lib/domain/ imports the data layer:"
  printf '%s\n' "$data_hits" | sed 's/^/      /'
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS  lib/domain/ is pure — no Flutter, no data-layer imports."
fi
exit "$fail"
