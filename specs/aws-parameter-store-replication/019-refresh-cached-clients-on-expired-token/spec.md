# Specification: Refresh cached destination clients on expired token errors

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

Full-sync mode caches assumed-role SSM clients for efficiency. If temporary credentials expire during long-running orchestration patterns, subsequent API calls can fail with `ExpiredToken*` errors and continue failing until the client is refreshed.

## Goal

Add a defensive refresh-and-retry path for expired token failures in full-sync mode.

## Scope

- Add helper in `src/common/utils.py` to detect expired token related errors.
- In `src/handler.py` full-sync loop, on expired-token failure:
  - clear cached destination clients,
  - retry the same parameter once.

## Out of Scope

- Introducing Step Functions/chunking semantics.
- Terraform interface changes.
- Any `CHANGELOG.md` changes.

## Acceptance Criteria

- Expired token errors in full sync trigger one refresh-and-retry attempt.
- Non-expired-token errors preserve current behavior.
- Code compiles and diagnostics are clean for changed files.
