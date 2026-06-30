# Specification: Ignore non-replicable EventBridge events without falling into manual 400 path

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

Certain Parameter Store Change events (invalid detail shape, non-Create/Update operations, invalid/empty name) should be ignored. If they are treated as non-EventBridge events, handler falls through to manual path and returns 400.

## Goal

Treat these events as EventBridge-origin but non-replicable so they are ignored cleanly.

## Scope

- Update `_extract_parameter_from_eventbridge` dispatch semantics in `src/handler.py`.
- Update `lambda_handler` EventBridge branch to skip replication when extracted name is missing.

## Out of Scope

- Terraform/IAM changes.
- `CHANGELOG.md` edits.

## Acceptance Criteria

- Non-Create/Update Parameter Store Change events are ignored (no manual 400).
- Invalid/non-string/empty EventBridge names are ignored (no manual 400).
- Non-EventBridge payloads keep existing behavior.
