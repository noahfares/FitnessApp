#!/usr/bin/env bash
# Everything CI checks, in CI's order, before pushing.
#
# CI's first gate is `dart format --set-exit-if-changed`, which fails the whole
# job before a single test runs — so a session that only ran the tests can push
# a red build with a green local suite. That happened; hence this.
#
#   tools/verify.sh        # check formatting, fail if it differs
#   tools/verify.sh --fix  # format in place, then check the rest
set -euo pipefail
cd "$(dirname "$0")/.."

export PATH="$PATH:/opt/flutter/bin"

# The flutter tool prints a root-user banner on every invocation in this
# container; it is advice, not output.
quiet() { grep -v -E -e 'flutter as root' -e 'without superuser' -e '📎' -e '^\s*/\s*$' || true; }

fix=false
[[ "${1:-}" == "--fix" ]] && fix=true

echo "== format"
if $fix; then
  dart format lib test 2>&1 | quiet | tail -1
else
  # Same invocation as .github/workflows/ci.yml, so a pass here is a pass there.
  if ! dart format --set-exit-if-changed --output=none lib test >/dev/null 2>&1; then
    echo "FAIL  formatting differs. Run: tools/verify.sh --fix"
    exit 1
  fi
  echo "PASS  formatting"
fi

echo "== analyze"
flutter analyze 2>&1 | quiet | tail -1

echo "== test"
./tools/test.sh

echo "== layers"
./tools/check-layers.sh

echo "== network"
./tools/check-network.sh | tail -2

echo "== strings"
./tools/check-strings.sh | tail -1

echo "== docs"
./tools/check-docs.sh | tail -1
