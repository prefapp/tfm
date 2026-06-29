# Specification: Align destination existence probe with tag-sync permissions

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

Current destination existence probe uses `ssm:GetParameter`. In restricted destination roles, this may be denied while `ssm:GetParameters` is the action effectively required by AWS for update-time tag APIs (`AddTagsToResource`/`ListTagsForResource`). This mismatch can trigger skip paths and warning noise even when destination permissions are otherwise close to valid for tag synchronization.

## Goal

Use destination existence probing aligned with AWS tag-sync permission requirements and clearly document required destination actions for successful tag replication.

## Scope

- Update destination existence probe in `src/common/replication.py` from `GetParameter` to `GetParameters` semantics.
- Update module docs to explicitly list destination role actions required for value replication and tag synchronization.
- Regenerate module `README.md` via `terraform-docs .`.

## Out of Scope

- Creating/managing destination account roles in this module.
- Any `CHANGELOG.md` changes.

## Acceptance Criteria

- Destination existence probe no longer depends on `ssm:GetParameter`.
- With destination role granting required actions (`PutParameter` + tag sync actions including `GetParameters`), update-time tag sync executes without access-denied warnings.
- Documentation clearly states required destination IAM actions.
