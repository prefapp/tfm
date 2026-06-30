# Specification: Skip destination tag sync when destination read is denied

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

After tightening destination-role permissions, value replication still succeeds via `PutParameter`, but update-time tag operations emit noisy warnings:

- stale-tag pruning path (`ListTagsForResource` / `RemoveTagsFromResource`)
- desired-tag apply path (`AddTagsToResource`)

In restricted roles that deny destination parameter reads, this creates repeated warning noise even though core replication succeeds.

## Goal

Avoid noisy warning spam by skipping destination tag synchronization when destination read access is denied during the existence probe, while preserving successful value replication.

## Scope

- Update `src/common/replication.py` tag-sync flow for update path.
- Emit a single explicit warning indicating tag sync is skipped due to destination read denial.

## Out of Scope

- Changes to destination IAM policies outside this module.
- Replication value semantics.
- Any `CHANGELOG.md` updates.

## Acceptance Criteria

- If destination existence probe is denied with `AccessDeniedException`, value replication continues in overwrite mode.
- Update-time tag pruning/apply calls are skipped for that destination/parameter in that run.
- Only one clear skip warning is logged (instead of failure warnings from each tag API).
