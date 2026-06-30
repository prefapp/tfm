# Specification: Honor explicit false for full-sync event flags

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

In unified `src/handler.py`, full-sync event flag resolution currently uses:

`event.get("enable_full_sync") or event.get("initial_run")`

This treats explicit `false` as missing, causing fallback to config defaults and potentially enabling full sync unintentionally.

## Goal

Distinguish between:
- key absent
- key present with explicit `false`
- key present with explicit `true`

so event-provided booleans are honored exactly.

## Scope

- Update flag resolution logic in `src/handler.py`.

## Out of Scope

- Terraform changes.
- IAM changes.
- Any `CHANGELOG.md` updates.

## Acceptance Criteria

- `{"enable_full_sync": false}` is honored as false (no fallback to config).
- `{"initial_run": false}` is honored as false when `enable_full_sync` is absent.
- Behavior for absent keys remains unchanged (fallback to config default).
