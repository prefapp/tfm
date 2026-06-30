# Specification: Skip expired-token retry when full-sync item lacks a real parameter name

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

In the full-sync error handler, retry logic for expired destination credentials falls back to placeholder parameter names such as `<missing-name>` or `<invalid-parameter-metadata>`. Those placeholders can then be passed to `replicate_parameter()` during retry, obscuring the real failure and causing a bogus retry attempt.

## Goal

Retry the failed full-sync item after refreshing credentials only when a real parameter name is available.

## Scope

- Update expired-token retry guard in `src/handler.py`.
- Preserve existing retry behavior for valid parameter names.
- Log clearly when retry is skipped due to missing/invalid parameter name context.

## Out of Scope

- Changes to replication logic outside the full-sync retry branch.
- Terraform or IAM changes.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Expired-token retry runs only when a real, non-empty parameter name is available.
- Placeholder/fallback names are not passed to `replicate_parameter()`.
- Handler syntax/diagnostics remain valid.
