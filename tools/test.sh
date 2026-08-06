#!/usr/bin/env bash
# Run the test suite quietly.
#
# `flutter test` prints a line per test — 254 of them, of which the interesting
# number is zero on a green run. This prints failures and a one-line summary,
# and drops pub's "newer versions available" preamble, which is re-emitted on
# every single invocation and never actionable here (versions are pinned).
#
#   tools/test.sh                      # everything
#   tools/test.sh test/domain          # a subtree
#   tools/test.sh -v test/foo_test.dart  # full per-test output when debugging
set -euo pipefail
cd "$(dirname "$0")/.."

export PATH="$PATH:/opt/flutter/bin"

reporter=failures-only
args=()
for arg in "$@"; do
  if [[ "$arg" == "-v" || "$arg" == "--verbose" ]]; then
    reporter=compact
  else
    args+=("$arg")
  fi
done

# Pub's resolution chatter goes to stdout mixed with test output, so it is
# filtered rather than redirected. Anything unrecognised still comes through:
# silence on an unexpected failure is the one thing worse than noise.
set +e
flutter test -r "$reporter" "${args[@]}" 2>&1 | grep -v -E \
  -e '^(Resolving dependencies|Downloading packages|Got dependencies)' \
  -e '^  [a-z_0-9]+ [0-9]+\.[0-9]+\.[0-9]+.*available\)$' \
  -e '^[0-9]+ packages have newer versions' \
  -e '^Try `flutter pub outdated`' \
  -e 'You appear to be trying to run flutter as root' \
  -e 'We strongly recommend running the flutter tool' \
  -e '📎' \
  -e '^\s*/\s*$'
status=${PIPESTATUS[0]}
set -e

exit "$status"
