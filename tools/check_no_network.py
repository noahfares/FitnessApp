#!/usr/bin/env python3
"""Prove the "no network calls" claim (ADR-0002, `F-REL-007`).

The privacy policy and both stores' data-safety declarations say this app makes
no network calls at all. That is the app's strongest differentiator, and it is
the one claim a user cannot check for themselves. `F-REL-007`'s acceptance
criterion is explicit that it must be *verified*, not asserted — so this runs in
CI beside the layer rule rather than living in a reviewer's head.

Two independent checks, because either alone is escapable:

1. **Source.** No file under lib/ imports a networking library or names a
   networking API. A `HttpClient` from `dart:io` needs no dependency at all, so
   a pubspec audit alone would miss it entirely.
2. **Dependencies.** No direct dependency in pubspec.yaml is a networking
   package. Source scanning alone would miss a package that phones home on our
   behalf — analytics SDKs are the textbook case.
3. **Manifest.** The Android app declares no `INTERNET` permission. This is the
   only one of the three the operating system itself enforces: without it a
   socket cannot be opened whatever the code says, which is what makes the
   claim cheap to keep honest.

Transitive dependencies are deliberately out of scope: a full audit of the
locked graph would flag `http` reaching in under `package_info_plus` and turn
into a permanent stream of false positives. What bounds the risk instead is the
first check plus every dependency in pubspec.yaml being justified by a comment
naming the feature that needs it (docs/60-ENGINEERING.md).

Run via tools/check-network.sh.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

LIB = Path("lib")

# Imports that put a network stack in reach. `dart:io` is not listed: it is how
# every file read, backup and export works (`F-DAT-*`), so it is banned by API
# below rather than wholesale.
BANNED_IMPORTS = {
    "dart:html": "browser networking",
    "package:http/": "HTTP client",
    "package:dio/": "HTTP client",
    "package:web_socket_channel/": "WebSocket client",
    "package:grpc/": "RPC client",
    "package:firebase_core/": "Firebase, which phones home by construction",
    "package:googleapis/": "Google APIs",
    "package:supabase_flutter/": "hosted backend",
}

# Networking APIs reachable from dart:io with no dependency of their own. Word
# boundaries on both sides: `Socket` must not match `SocketDirectory`, and a
# comment mentioning one of these by name is not a call.
BANNED_APIS = {
    r"\bHttpClient\b": "dart:io HTTP client",
    r"\bSocket\.connect\b": "raw socket",
    r"\bRawDatagramSocket\b": "UDP socket",
    r"\bServerSocket\b": "listening socket",
    r"\bWebSocket\.connect\b": "WebSocket",
    r"\bInternetAddress\.lookup\b": "DNS lookup",
}

# Networking packages that must never appear as a direct dependency.
BANNED_PACKAGES = {
    "http", "dio", "web_socket_channel", "grpc", "googleapis",
    "firebase_core", "firebase_analytics", "firebase_crashlytics",
    "sentry_flutter", "posthog_flutter", "amplitude_flutter", "mixpanel_flutter",
    "supabase_flutter", "cloud_firestore", "google_sign_in", "sign_in_with_apple",
}

# url_launcher hands a URL to the *system browser* — the user's own network
# call, in their own app, not ours (`F-SET-009`). Named here so the exception is
# a decision on the record rather than a gap.
ALLOWED_WITH_REASON = {
    "url_launcher": "opens the user's browser; the app itself sends nothing",
}


def strip_comments(source: str) -> str:
    """Line and block comments removed, so prose about networking is not a hit."""
    source = re.sub(r"/\*.*?\*/", "", source, flags=re.S)
    return "\n".join(line.split("//")[0] for line in source.splitlines())


def scan_sources() -> list[str]:
    failures = []
    for path in sorted(LIB.rglob("*.dart")):
        code = strip_comments(path.read_text())
        for needle, what in BANNED_IMPORTS.items():
            if re.search(rf"""import\s+['"]{re.escape(needle)}""", code):
                failures.append(f"{path}: imports {needle} ({what})")
        for pattern, what in BANNED_APIS.items():
            if re.search(pattern, code):
                failures.append(f"{path}: uses {pattern.strip(chr(92)+'b')} ({what})")
    return failures


def scan_dependencies() -> list[str]:
    """Direct dependencies only — the `dependencies:` block, not dev or transitive."""
    lines = Path("pubspec.yaml").read_text().splitlines()
    try:
        start = lines.index("dependencies:")
    except ValueError:
        return ["pubspec.yaml: no dependencies: block found"]

    failures = []
    for line in lines[start + 1:]:
        if line and not line[0].isspace():
            break
        match = re.match(r"  ([a-z0-9_]+):", line)
        if not match:
            continue
        name = match.group(1)
        if name in BANNED_PACKAGES:
            failures.append(f"pubspec.yaml: depends on {name}, a networking package")
    return failures


# Permissions that would contradict the policy outright. The manifest declares
# none at all today; this names the one that matters most if that ever changes.
BANNED_PERMISSIONS = {
    "android.permission.INTERNET": "opening a socket at all",
    "android.permission.ACCESS_NETWORK_STATE": "observing connectivity",
}

MANIFESTS = [
    Path("android/app/src/main/AndroidManifest.xml"),
    Path("android/app/src/release/AndroidManifest.xml"),
]


def scan_manifests() -> list[str]:
    failures = []
    for manifest in MANIFESTS:
        if not manifest.exists():
            continue
        text = manifest.read_text()
        for permission, what in BANNED_PERMISSIONS.items():
            if permission in text:
                failures.append(f"{manifest}: declares {permission} ({what})")
    return failures


def main() -> int:
    failures = scan_sources() + scan_dependencies() + scan_manifests()
    if failures:
        print("FAIL  the app must make no network calls (ADR-0002, F-REL-007)")
        for failure in failures:
            print(f"      {failure}")
        print()
        print("      A deliberate exception belongs in ADR-0002 and in")
        print("      PRIVACY.md before it belongs in this allowlist — the")
        print("      store declarations are written against this rule.")
        return 1

    allowed = ", ".join(f"{k} ({v})" for k, v in ALLOWED_WITH_REASON.items())
    dart_files = sum(1 for _ in LIB.rglob("*.dart"))
    print(f"PASS  no network calls in {dart_files} file(s) under lib/, "
          f"no networking dependency, no INTERNET permission.")
    print(f"      By exception: {allowed}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
