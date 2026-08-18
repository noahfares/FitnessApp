#!/usr/bin/env python3
"""Keep user-facing text in the ARB file (`F-I18N-001`).

The feature's own rationale is that retrofitting extraction across a finished
app is miserable and never quite complete. Having paid that cost once, this is
what stops it accruing again: a literal that reaches a screen fails the build
the day it is written, not two years later.

Scope — presentation code only (`lib/features/**/presentation/`,
`lib/features/shell/widgets/`). Deliberately outside it:

- **SQL**, `toString()` output, and log text. Not user-facing.
- **`lib/domain/`** — starter-program names, attribution lines and the like are
  proper nouns and citations, not translatable prose (and the domain layer
  cannot import Flutter anyway).
- **`lib/data/`** — no BuildContext exists there. Text that needs localising is
  returned as an outcome the UI words, which is how `RestoreService` and
  `SessionPr.exerciseName` already work.

Run via tools/check-strings.sh.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOTS = [Path("lib/features")]
PRESENTATION = ("presentation", "widgets")

# The argument positions that put a string in front of someone.
POSITIONS = re.compile(
    r"(?:\bText\(\s*|\b(?:tooltip|hintText|labelText|helperText|semanticLabel|"
    r"semanticsLabel|metricLabel|errorTitle|errorMessage|confirmLabel|"
    r"cancelLabel|actionLabel|addLabel|title|subtitle|message|label)\s*:\s*)"
    r"(?:const\s+)?'(?P<s>(?:[^'\\\n]|\\.){4,})'"
)

ALLOWED = re.compile(r"^[^A-Za-z]*$|^\S+$")


def offenders(path: Path) -> list[tuple[int, str]]:
    src = path.read_text()
    # Comments first: prose about strings is not a string.
    src = re.sub(r"/\*.*?\*/", "", src, flags=re.S)
    src = "\n".join(line.split("//")[0] for line in src.splitlines())

    found = []
    for m in POSITIONS.finditer(src):
        text = m.group("s")
        if "$" in text:
            continue  # interpolation: composition, checked by eye not by regex
        if ALLOWED.match(text):
            continue  # single words and symbols — units, separators, initials
        if " " not in text:
            continue
        found.append((src[: m.start()].count("\n") + 1, text))
    return found


def main() -> int:
    failures = []
    scanned = 0
    for root in ROOTS:
        for path in sorted(root.rglob("*.dart")):
            if not any(part in PRESENTATION for part in path.parts):
                continue
            scanned += 1
            for line, text in offenders(path):
                failures.append(f"{path}:{line}: {text[:60]}")

    if failures:
        print("FAIL  user-facing text must live in lib/l10n/app_en.arb "
              "(F-I18N-001)")
        for failure in failures:
            print(f"      {failure}")
        print()
        print("      Add a key to the ARB, run `flutter gen-l10n`, and read it")
        print("      through `context.l10n`.")
        return 1

    print(f"PASS  no unlocalised user-facing text in {scanned} presentation "
          f"file(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
