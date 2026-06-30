# Specification: Validate manual `parameter_name` input before replication

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

Manual invocation currently accepts `parameter_name` without validating type or trimming whitespace. Non-string values and whitespace-only strings can propagate into boto3 calls and fail later with `500` instead of returning a clear `400` input error.

## Goal

Validate manual `parameter_name` payload early and return `400` for invalid values.

## Scope

- Update `src/handler.py` manual invocation input handling.
- Accept only non-empty strings for `parameter_name` (after trimming).
- Keep existing behavior for valid manual, EventBridge, and full-sync invocation modes.

## Out of Scope

- Terraform/IAM changes.
- Replication logic changes outside input validation.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Non-string `parameter_name` returns `400` with clear message.
- Whitespace-only `parameter_name` returns `400` with clear message.
- Valid string `parameter_name` is trimmed and processed normally.
- Python syntax/diagnostics remain valid.
