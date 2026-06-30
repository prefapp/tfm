# Specification: Apply desired tags best-effort when destination read is denied

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

When destination existence probing (`GetParameters`) is denied, current logic forces overwrite mode and skips all update-time tag synchronization. This can leave destination parameters without replication metadata tags because update/create via `PutParameter` with `Overwrite = true` does not include tags.

## Goal

Preserve replication progress in read-denied environments while still attempting desired tag application (`AddTagsToResource`) on a best-effort basis. Continue skipping stale-tag pruning that depends on destination tag reads.

## Scope

- Update tag-sync control flow in `src/common/replication.py` for read-denied probe scenarios.
- Keep stale-tag pruning disabled when destination reads are denied.
- Keep desired-tag application independent and best-effort.

## Out of Scope

- Destination IAM policy management changes.
- Behavior changes outside tag-sync control flow.
- `CHANGELOG.md` edits.

## Acceptance Criteria

- On destination read denial, replication still uses overwrite mode.
- Stale-tag pruning is skipped in read-denied path.
- Desired tags are still attempted via `AddTagsToResource` (best effort).
- Logging clearly indicates pruning skip reason without suppressing desired-tag application attempt.
