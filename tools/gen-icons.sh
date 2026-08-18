#!/usr/bin/env bash
# Regenerate the app icon, adaptive icon and store graphics (`F-THM-006`).
# The mark is a script, not a binary — see tools/gen_icons.py.
set -euo pipefail
cd "$(dirname "$0")/.."
exec python3 tools/gen_icons.py "$@"
