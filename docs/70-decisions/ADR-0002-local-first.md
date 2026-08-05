# ADR-0002 — Local-first, no backend

**Status:** Accepted · 2026-08

## Context

Competing apps sync across devices and back up to a cloud account, which is one
of the things their subscriptions pay for. The obvious instinct is to match that.

## Options

**Backend with accounts.** Sync, cloud backup, web access, a foundation for
sharing features. Cost: authentication, password resets, GDPR and data-deletion
obligations, hosting bills, uptime responsibility, a security surface, and a
permanent operational liability attached to an app nobody pays for. When the
maintainer loses interest, users lose their data.

**Local-only, with export.** No server, no account, no obligations. Data lives on
the device and can be exported at any time. Cost: no automatic sync; device loss
without a backup means data loss.

**Local-first with file-based sync.** Local database, synced as a file through
the user's own cloud storage (Drive, iCloud, Nextcloud). No server of ours. Cost:
whole-file last-write-wins, which loses data under genuine concurrent
multi-device editing.

## Decision

**Local-only for v1, with export/import (`F-DAT-001`–`F-DAT-004`) as the data
safety mechanism.** File-based sync (`F-DAT-009`) is kept as an explicitly
unscheduled option. A server is a documented non-goal.

The sequence is: manual export → backup/restore → optional file sync. True
multi-device merge only if all three prove insufficient in practice.

## Consequences

- **No account, no telemetry, no network calls at all.** This is the app's
  strongest differentiator and makes the store privacy declarations
  (`F-REL-007`) trivially honest.
- Export/import stops being a nice-to-have and becomes safety-critical — which
  is why it's scheduled before any public release.
- Device loss without a backup means data loss. Mitigated by automatic local
  backups (`F-DAT-008`) and by making export prominent rather than buried.
- Multi-device users are inconvenienced. Accepted.
- Any future crash reporting (`F-REL-011`) or update check (`F-REL-008`) would
  contradict the "no network" claim, so both must be opt-in and disclosed.
- The project can be abandoned without stranding anyone. Nothing stops working
  when a server bill goes unpaid.

## Reversal cost

Medium. Adding sync later means designing a merge strategy and adding identity,
but nothing in the local schema prevents it — stable UUIDs on every entity exist
partly to keep that door open.

Note the asymmetry: adding a backend later is possible. Removing one, once users
depend on it, is not.
