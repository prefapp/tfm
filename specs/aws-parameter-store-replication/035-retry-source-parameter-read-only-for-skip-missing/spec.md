# Specification: Retry source parameter reads only for skip-missing flows

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

`_get_parameter_value_with_retry()` currently retries `ParameterNotFound` even when `skip_missing = false`. For manual invocation, this adds avoidable latency and warning noise in cases where the correct behavior is to fail fast.

## Goal

Restrict `ParameterNotFound` retries to invocation flows that explicitly opt into eventual-consistency tolerance via `skip_missing = true`.

## Scope

- Update `_get_parameter_value_with_retry()` in `src/common/replication.py`.
- Preserve retry/skip behavior for EventBridge-style flows using `skip_missing = true`.
- Fail fast for manual flows using `skip_missing = false`.

## Out of Scope

- Changes to destination replication behavior.
- Terraform/IAM/doc changes.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- When `skip_missing = false`, `ParameterNotFound` is raised immediately with no retry delay or retry warning logs.
- When `skip_missing = true`, existing retry-and-skip behavior remains intact.
- Python syntax/diagnostics remain valid.
