# Specification: Enforce strict handler input sanitization for manual invocations

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

Current handler validation prevents obvious type issues, but still allows ambiguous string values in full-sync flags and may defer malformed `parameter_name` values to boto3/runtime errors. This can cause surprising behavior at invocation time.

## Goal

Harden manual/event inputs to fail early with clear `400` responses for malformed values and ambiguous flag strings.

## Scope

- Update `src/handler.py` input parsing/validation.
- Enforce stricter `parameter_name` sanitization (non-empty string, no whitespace characters, length bounds).
- Enforce strict string parsing for full-sync flags: accept only known true/false tokens.

## Out of Scope

- Terraform/IAM changes.
- Replication logic changes outside handler input sanitization.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Invalid `parameter_name` values are rejected with `400` before replication calls.
- Unknown full-sync string tokens (e.g. "maybe") are rejected with `400`.
- Existing valid bool inputs and supported string tokens continue working.
- Python syntax/diagnostics remain valid.
