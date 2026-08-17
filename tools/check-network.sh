#!/usr/bin/env bash
# Verify the claim the whole privacy story rests on (ADR-0002, `F-REL-007`):
#
#   the app makes no network calls at all.
#
# Runs in CI as a required check. See tools/check_no_network.py for what is
# checked and what is deliberately out of scope.
set -euo pipefail
cd "$(dirname "$0")/.."
exec python3 tools/check_no_network.py "$@"
