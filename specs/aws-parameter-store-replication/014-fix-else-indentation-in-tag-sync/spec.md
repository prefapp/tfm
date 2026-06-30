# Specification: Fix else indentation in tag-sync update path

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

The `else:` branch in the update-time tag sync section had misleading indentation for the first in-branch comment, making the block appear empty during review and increasing risk of syntax/maintenance errors.

## Goal

Make the `else:` body explicitly and correctly indented for readability and safety.

## Scope

- Adjust indentation in `src/common/replication.py` under update-time tag-sync `else:` branch.

## Out of Scope

- Behavior changes in replication logic.
- IAM policy changes.
- Any `CHANGELOG.md` modifications.

## Acceptance Criteria

- `else:` block clearly contains pruning/tag-apply logic.
- File diagnostics show no new syntax errors after the edit.
