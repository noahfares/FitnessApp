#!/usr/bin/env bash
# Regenerate docs/features.tsv and docs/30-features/INDEX.md from the feature
# files. Both are generated artefacts — never hand-edit them.
set -euo pipefail
cd "$(dirname "$0")/.."
exec python3 tools/gen_index.py "$@"
