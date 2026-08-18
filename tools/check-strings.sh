#!/usr/bin/env bash
# User-facing text belongs in lib/l10n/app_en.arb (`F-I18N-001`).
#
# Runs in CI as a required check — see tools/check_strings.py for what is in
# scope and what is deliberately not.
set -euo pipefail
cd "$(dirname "$0")/.."
exec python3 tools/check_strings.py "$@"
