#!/usr/bin/env python3
"""Generate the app icon, adaptive icon and store graphics (`F-THM-006`).

A script rather than checked-in binaries someone has to open a design tool to
change: the mark is a few shapes and a colour, and the colour is the same seed
`AppTheme.seed` uses. Change it here, re-run, and every density and both store
graphics follow — which is the only way five sizes of the same icon stay the
same icon.

Original artwork: a barbell drawn from rectangles. Nothing traced, nothing
sourced, no font dependency (the wordmark is drawn, not typeset).

PNG encoding is done by hand — zlib plus four chunks — because the alternative
is a Pillow dependency in a repository whose only Python is these tools.

    python3 tools/gen_icons.py

Run via tools/gen-icons.sh.
"""
from __future__ import annotations

import struct
import zlib
from pathlib import Path

SEED = (0x00, 0x71, 0xE3)          # AppTheme.seed — one accent, everywhere.
ON_SEED = (0xFF, 0xFF, 0xFF)
SCALE = 4                           # supersampling factor for smooth edges


class Canvas:
    """An RGBA canvas with the handful of primitives this mark needs."""

    def __init__(self, size: int, background=None):
        self.size = size
        self.px = bytearray(size * size * 4)
        if background is not None:
            self.fill_rect(0, 0, size, size, background)

    def fill_rect(self, x0, y0, x1, y1, colour, radius: float = 0.0):
        r, g, b = colour
        for y in range(max(0, int(y0)), min(self.size, int(y1))):
            for x in range(max(0, int(x0)), min(self.size, int(x1))):
                if radius > 0 and not _inside_rounded(x, y, x0, y0, x1, y1, radius):
                    continue
                i = (y * self.size + x) * 4
                self.px[i : i + 4] = bytes((r, g, b, 255))

    def downsample(self, factor: int) -> "Canvas":
        out = Canvas(self.size // factor)
        for y in range(out.size):
            for x in range(out.size):
                r = g = b = a = 0
                for dy in range(factor):
                    for dx in range(factor):
                        i = ((y * factor + dy) * self.size + (x * factor + dx)) * 4
                        r += self.px[i]
                        g += self.px[i + 1]
                        b += self.px[i + 2]
                        a += self.px[i + 3]
                n = factor * factor
                j = (y * out.size + x) * 4
                out.px[j : j + 4] = bytes((r // n, g // n, b // n, a // n))
        return out

    def write(self, path: Path):
        raw = bytearray()
        for y in range(self.size):
            raw.append(0)  # filter type 0
            row = (y * self.size) * 4
            raw.extend(self.px[row : row + self.size * 4])
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(
            b"\x89PNG\r\n\x1a\n"
            + _chunk(b"IHDR", struct.pack(">IIBBBBB", self.size, self.size, 8, 6, 0, 0, 0))
            + _chunk(b"IDAT", zlib.compress(bytes(raw), 9))
            + _chunk(b"IEND", b"")
        )


def _chunk(kind: bytes, data: bytes) -> bytes:
    return (
        struct.pack(">I", len(data))
        + kind
        + data
        + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
    )


def _inside_rounded(x, y, x0, y0, x1, y1, radius) -> bool:
    cx = min(max(x, x0 + radius), x1 - radius)
    cy = min(max(y, y0 + radius), y1 - radius)
    return (x - cx) ** 2 + (y - cy) ** 2 <= radius**2


def draw_barbell(canvas: Canvas, size: int, colour, cx: float, cy: float, width: float):
    """A barbell, seen from the front: sleeve, inner plates, outer plates.

    Proportioned rather than measured — the plates step down in height from the
    middle out, which is what makes it read as a barbell at 48 px instead of a
    row of rectangles.
    """
    unit = width / 14
    bar_h = unit * 1.1
    canvas.fill_rect(cx - width / 2, cy - bar_h / 2, cx + width / 2, cy + bar_h / 2, colour, bar_h / 2)

    for offset, plate_h, plate_w in (
        (3.0, 7.0, 1.5),   # inner plate: the tall one
        (5.0, 4.6, 1.3),   # outer plate
    ):
        for direction in (-1, 1):
            x = cx + direction * offset * unit
            canvas.fill_rect(
                x - plate_w * unit / 2,
                cy - plate_h * unit / 2,
                x + plate_w * unit / 2,
                cy + plate_h * unit / 2,
                colour,
                unit * 0.45,
            )


def launcher_icon(size: int) -> Canvas:
    big = Canvas(size * SCALE)
    big.fill_rect(0, 0, size * SCALE, size * SCALE, SEED, radius=size * SCALE * 0.22)
    draw_barbell(big, size * SCALE, ON_SEED, size * SCALE / 2, size * SCALE / 2, size * SCALE * 0.62)
    return big.downsample(SCALE)


def adaptive_foreground(size: int) -> Canvas:
    """Transparent, with the glyph inside the 66% safe zone Android crops to."""
    big = Canvas(size * SCALE)
    draw_barbell(big, size * SCALE, ON_SEED, size * SCALE / 2, size * SCALE / 2, size * SCALE * 0.40)
    return big.downsample(SCALE)


def feature_graphic() -> Canvas:
    """1024×500 for the Play listing (`F-REL-006`), cropped from a square."""
    width, height = 1024, 500
    big = Canvas(1024 * 2)
    big.fill_rect(0, 0, 2048, 2048, SEED)
    draw_barbell(big, 2048, ON_SEED, 2048 * 0.30, 2048 * 0.5, 2048 * 0.30)
    square = big.downsample(2)

    out = Canvas(width)
    for y in range(height):
        src = (1024 - height) // 2 + y
        out.px[(y * width) * 4 : (y * width + width) * 4] = square.px[
            (src * 1024) * 4 : (src * 1024 + width) * 4
        ]
    out.size_h = height
    return out


def write_cropped(canvas: Canvas, width: int, height: int, path: Path):
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        row = (y * canvas.size) * 4
        raw.extend(canvas.px[row : row + width * 4])
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + _chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
        + _chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + _chunk(b"IEND", b"")
    )


def main():
    res = Path("android/app/src/main/res")

    # Legacy launcher icons, one per density.
    for folder, size in (
        ("mipmap-mdpi", 48),
        ("mipmap-hdpi", 72),
        ("mipmap-xhdpi", 96),
        ("mipmap-xxhdpi", 144),
        ("mipmap-xxxhdpi", 192),
    ):
        launcher_icon(size).write(res / folder / "ic_launcher.png")

    # Adaptive icon foreground: 108 dp at each density, glyph in the safe zone.
    for folder, size in (
        ("drawable-mdpi", 108),
        ("drawable-hdpi", 162),
        ("drawable-xhdpi", 216),
        ("drawable-xxhdpi", 324),
        ("drawable-xxxhdpi", 432),
    ):
        adaptive_foreground(size).write(res / folder / "ic_launcher_foreground.png")

    # Store assets (`F-REL-006`).
    launcher_icon(512).write(Path("store/play-icon-512.png"))
    write_cropped(feature_graphic(), 1024, 500, Path("store/play-feature-graphic.png"))

    print("wrote launcher icons, adaptive foregrounds and store graphics")


if __name__ == "__main__":
    main()
