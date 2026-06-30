# Specification: Clarify manual handler 400 message

**Date:** 2026-06-26
**Module:** `modules/aws-parameter-store-replication`

## Problem

The manual replication Lambda returns a `400` message saying `enable_full_sync` must be provided when no `parameter_name` is sent. This is misleading because callers can provide `enable_full_sync = false` and still correctly receive a `400`.

## Goal

Clarify the error message so it states the actual requirement: either provide `parameter_name`, or set `enable_full_sync` to `true`.

## Scope

- Update only the `400` response message in `src/lambda_manual_replication/handler.py`

## Out of Scope

- Any logic changes in full sync/manual sync behavior
- Any Terraform code or docs regeneration
- Any `CHANGELOG.md` updates

## Acceptance Criteria

- The `400` response body message is:
  `Either 'parameter_name' must be provided, or 'enable_full_sync' must be true.`
- No behavior change beyond message wording
