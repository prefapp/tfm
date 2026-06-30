# Specification: Enforce integer validation for async retry attempts

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

`lambda_async_maximum_retry_attempts` is declared as `number` with range validation `0..2`, but values like `1.5` pass Terraform variable validation and then fail at resource plan/apply because `aws_lambda_function_event_invoke_config.maximum_retry_attempts` requires an integer.

## Goal

Harden module input validation so only integer values in range `0..2` are accepted.

## Scope

- Update `variables.tf` validation for `lambda_async_maximum_retry_attempts`.
- Keep variable type as `number` for backward compatibility while enforcing integer semantics via validation.
- Regenerate `README.md` via `terraform-docs .` per repository process.

## Out of Scope

- Resource behavior changes beyond input validation.
- Provider/resource schema changes.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Validation rejects non-integer values (e.g., `1.5`).
- Validation accepts integers `0`, `1`, `2`.
- Module docs are regenerated successfully.
