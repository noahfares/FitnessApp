#!/usr/bin/env bash
# Enforce the central architectural invariant (docs/20-ARCHITECTURE.md):
#
#   lib/domain/ imports nothing from Flutter and nothing from lib/data/.
#
# Checked transitively — see tools/check_layers.py for why a grep is not enough.
# Runs in CI (F-REL-001) as a required check, not advice.
set -euo pipefail
cd "$(dirname "$0")/.."
exec python3 tools/check_layers.py "$@"
