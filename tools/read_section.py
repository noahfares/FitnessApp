#!/usr/bin/env python3
"""Print one named section of a planning document.

Serves the `Reads:` line on every feature file. `Reads: 21-DATA-MODEL#sets`
names a section, but without this there is no way to read *only* that section —
the file is 324 lines and the section is 30, and the rest arrives as context
nobody asked for.

Usage:
    tools/read.sh 21-DATA-MODEL#sets
    tools/read.sh 24-DESIGN-SYSTEM#component-inventory
    tools/read.sh F-LOG-003            # feature file, minus its `## Why`
    tools/read.sh ADR-0008 --all       # nothing omitted
"""

from __future__ import annotations

import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def slug(heading: str) -> str:
    """GitHub-style anchor for a heading, ignoring code ticks and links."""
    text = heading.strip().lstrip("#").strip()
    text = re.sub(r"`|\*|\[|\]|\(.*?\)", "", text)
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9\s-]", "", text)
    return re.sub(r"\s+", "-", text)


def resolve(name: str) -> str:
    """Find the file behind a document name, feature ID or ADR number."""
    name = name.strip()
    candidates = [
        name,
        os.path.join(ROOT, name),
        os.path.join(ROOT, f"{name}.md"),
        os.path.join(ROOT, "docs", f"{name}.md"),
        os.path.join(ROOT, "docs", name),
    ]
    for path in candidates:
        if os.path.isfile(path):
            return path

    patterns = [
        os.path.join(ROOT, "docs", "30-features", "*", f"{name}.md"),
        os.path.join(ROOT, "docs", "70-decisions", f"{name}*.md"),
        os.path.join(ROOT, "docs", f"*{name}*.md"),
    ]
    for pattern in patterns:
        matches = sorted(glob.glob(pattern))
        if matches:
            return matches[0]

    sys.exit(f"read: no document matching {name!r}")


def heading_level(line: str) -> int:
    return len(line) - len(line.lstrip("#"))


def section(lines: list[str], anchor: str) -> list[str]:
    """The named heading and everything under it, up to the next peer heading."""
    wanted = slug(anchor)
    start = None
    level = 0
    for i, line in enumerate(lines):
        if not line.startswith("#"):
            continue
        current = slug(line)
        # Exact match wins; a prefix match saves retyping a long heading.
        if current == wanted or current.startswith(wanted + "-"):
            start = i
            level = heading_level(line)
            break
    if start is None:
        available = [slug(l) for l in lines if l.startswith("#")]
        sys.exit(
            f"read: no section {anchor!r}. Available: {', '.join(available)}"
        )

    end = len(lines)
    for i in range(start + 1, len(lines)):
        if lines[i].startswith("#") and heading_level(lines[i]) <= level:
            end = i
            break
    return lines[start:end]


def drop_why(lines: list[str]) -> tuple[list[str], bool]:
    """Feature files end in rationale for the human, which the build skips."""
    for i, line in enumerate(lines):
        if line.startswith("## Why"):
            # The `---` rule immediately above belongs to the Why section.
            cut = i
            while cut > 0 and lines[cut - 1].strip() in {"", "---"}:
                cut -= 1
            return lines[:cut], True
    return lines, False


def main(argv: list[str]) -> None:
    args = [a for a in argv[1:] if not a.startswith("--")]
    keep_all = "--all" in argv
    if len(args) != 1:
        sys.exit(__doc__)

    target = args[0]
    name, _, anchor = target.partition("#")
    path = resolve(name)
    lines = open(path).read().splitlines()

    omitted = False
    if anchor:
        lines = section(lines, anchor)
    elif not keep_all and "30-features" in path:
        lines, omitted = drop_why(lines)

    rel = os.path.relpath(path, ROOT)
    print(f"# {rel}" + (f" § {anchor}" if anchor else ""))
    print()
    print("\n".join(lines).strip())
    if omitted:
        print()
        print("<!-- `## Why` omitted; pass --all to include it. -->")


if __name__ == "__main__":
    main(sys.argv)
