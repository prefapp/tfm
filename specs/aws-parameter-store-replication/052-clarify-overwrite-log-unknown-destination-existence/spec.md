# Specification: Clarify overwrite log when destination existence is unknown

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

When destination existence probing is denied (`AccessDeniedException`), replication switches to overwrite mode with `param_exists = True`. The current log message says "Updating parameter in destination", which can be misleading because `Overwrite=True` may create the parameter if it does not exist.

## Goal

Log a distinct message for overwrite mode with unknown destination existence so operators can accurately interpret runtime behavior.

## Scope

- `src/common/replication.py` log message selection only.

## Out of Scope

- Behavior changes to replication flow or IAM assumptions.
- Terraform/docs changes.
- `CHANGELOG.md` updates.

## Acceptance Criteria

- When `destination_read_denied` is true and overwrite mode is used, log uses distinct wording indicating unknown existence.
- Existing create/update logic and API calls remain unchanged.
