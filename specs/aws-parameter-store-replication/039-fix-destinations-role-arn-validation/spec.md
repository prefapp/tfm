# Specification: Fix ineffective destinations role ARN format validation

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The `destinations_json` role ARN validation currently uses `can(alltrue([...]))`, which only verifies that the expression is evaluable, not that the result is `true`. Invalid `role_arn` values can therefore pass validation and fail later during IAM/policy operations.

## Goal

Make validation enforce that every destination `role_arn` matches the expected IAM role ARN pattern.

## Scope

- Update `variables.tf` validation condition for destination `role_arn` format.
- Keep existing validation message semantics and expected ARN format.
- Regenerate module `README.md` via `terraform-docs .` per repo workflow.
- Validate Terraform after the change.

## Out of Scope

- Runtime code changes.
- IAM resource logic changes.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Invalid `role_arn` values fail variable validation.
- Valid IAM role ARNs continue to pass.
- `terraform validate` succeeds.
- `README.md` regenerated successfully.
