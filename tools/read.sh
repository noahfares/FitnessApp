#!/usr/bin/env bash
# Print one named section of a planning document — the `Reads:` line, made
# executable. See tools/read_section.py.
#
#   tools/read.sh 21-DATA-MODEL#sets
#   tools/read.sh F-LOG-003
set -euo pipefail
cd "$(dirname "$0")/.."
exec python3 tools/read_section.py "$@"
