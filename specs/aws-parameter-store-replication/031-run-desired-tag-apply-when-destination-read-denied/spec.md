# Specification: Ensure desired-tag application executes when destination read is denied

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

In update flows where destination existence probing is denied, the code logs that desired tags will be applied best-effort, but `AddTagsToResource` remains nested in the non-read-denied branch. As a result, desired tags are not actually applied in the read-denied path.

## Goal

Make desired-tag application run best-effort for update paths regardless of destination-read denial, while still skipping stale-tag pruning when destination reads are denied.

## Scope

- Adjust control flow in `src/common/replication.py` to decouple desired-tag apply from stale-tag pruning branch.
- Keep existing overwrite fallback and stale-tag pruning skip behavior.

## Out of Scope

- Destination IAM policy changes.
- Changes outside replication tag-sync flow.
- `CHANGELOG.md` edits.

## Acceptance Criteria

- In update mode (`param_exists = true`), desired-tag apply is attempted in both read-denied and non-read-denied paths.
- Stale-tag pruning remains skipped when destination reads are denied.
- Diagnostics/syntax checks pass for changed files.
