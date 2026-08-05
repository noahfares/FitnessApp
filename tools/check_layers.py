#!/usr/bin/env python3
"""Enforce the architectural purity rules (docs/20-ARCHITECTURE.md).

  lib/domain/ imports nothing from Flutter and nothing from lib/data/.

Checked *transitively*. A direct-import grep is not enough: if a domain file
imports lib/core/units/mass.dart and that file imports Flutter, the domain
layer depends on Flutter, and every calculation in it stops being testable as
plain Dart.

lib/core/units/ and lib/core/formatting/ are checked too. They are documented
as pure precisely so domain can use them (docs/22-UNITS.md), which makes their
purity load-bearing rather than incidental.

Run via tools/check-layers.sh.
"""
from __future__ import annotations

import os
import re
import sys

LIB = "lib"
PACKAGE = "fitness_app"

# Directories whose contents must be pure Dart, with why — printed on failure
# so the fix is obvious rather than mysterious.
PURE_ROOTS = {
    "lib/domain": "all maths that can be silently wrong lives here, as testable plain Dart",
    "lib/core/units": "domain imports these, so they must stay Flutter-free",
    "lib/core/formatting": "domain-adjacent and documented pure in docs/22-UNITS.md",
}

IMPORT_RE = re.compile(r"""^\s*(?:import|export)\s+['"]([^'"]+)['"]""", re.M)


def dart_files(root: str) -> list[str]:
    found = []
    for dirpath, _, filenames in os.walk(root):
        for name in filenames:
            if name.endswith(".dart"):
                found.append(os.path.normpath(os.path.join(dirpath, name)))
    return found


def imports_of(path: str) -> list[str]:
    try:
        with open(path, encoding="utf-8") as handle:
            return IMPORT_RE.findall(handle.read())
    except OSError:
        return []


def resolve(importing_file: str, uri: str) -> str | None:
    """Map an import URI to a path inside lib/, or None if it leaves the package."""
    if uri.startswith(f"package:{PACKAGE}/"):
        return os.path.normpath(os.path.join(LIB, uri[len(f"package:{PACKAGE}/"):]))
    if uri.startswith(("package:", "dart:")):
        return None
    return os.path.normpath(os.path.join(os.path.dirname(importing_file), uri))


def violation(uri: str, resolved: str | None) -> str | None:
    """Why this import is forbidden, or None if it is fine."""
    if re.match(r"^package:flutter(_[a-z_]+)?/", uri):
        return f"imports Flutter ({uri})"
    if resolved and resolved.startswith(os.path.join(LIB, "data") + os.sep):
        return f"imports the data layer ({uri})"
    return None


def main() -> int:
    if not os.path.isdir(LIB):
        print("lib/ does not exist yet — nothing to check.")
        return 0

    failures: list[str] = []

    for root, reason in sorted(PURE_ROOTS.items()):
        if not os.path.isdir(root):
            continue

        for start in sorted(dart_files(root)):
            # Depth-first, tracking how we got here so the report names the
            # whole chain rather than just the offending file.
            stack: list[tuple[str, list[str]]] = [(start, [start])]
            seen: set[str] = set()

            while stack:
                current, chain = stack.pop()
                if current in seen:
                    continue
                seen.add(current)

                for uri in imports_of(current):
                    resolved = resolve(current, uri)
                    why = violation(uri, resolved)
                    if why:
                        arrow = "\n        -> ".join(chain)
                        failures.append(
                            f"  {start}\n"
                            f"    {why}\n"
                            f"    via: {arrow}\n"
                            f"    ({root}: {reason})"
                        )
                        continue
                    if resolved and resolved.endswith(".dart") and os.path.isfile(resolved):
                        stack.append((resolved, chain + [resolved]))

    if failures:
        print("FAIL  purity rule violated:\n")
        print("\n\n".join(failures))
        print("\nSee docs/20-ARCHITECTURE.md.")
        return 1

    checked = sum(len(dart_files(r)) for r in PURE_ROOTS if os.path.isdir(r))
    print(f"PASS  {checked} file(s) under {', '.join(sorted(PURE_ROOTS))} are pure "
          f"(checked transitively).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
