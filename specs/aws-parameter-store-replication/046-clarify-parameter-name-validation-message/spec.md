# Specification: Clarify manual `parameter_name` validation error message

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

Manual invocation currently returns a `400` message stating `parameter_name` must be a non-empty string. Runtime validation is stricter: names containing whitespace and names longer than 2048 characters are also rejected. The current message can mislead callers.

## Goal

Update error messaging so it accurately describes the enforced `parameter_name` constraints.

## Scope

- Update manual invalid-`parameter_name` response text in `src/handler.py`.
- Keep existing validation rules and behavior unchanged.

## Out of Scope

- Terraform/IAM changes.
- Input validation logic changes.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Error message clearly indicates `parameter_name` must be non-empty, contain no whitespace, and be <= 2048 chars.
- Handler behavior remains unchanged.
- Python syntax/diagnostics remain valid.
