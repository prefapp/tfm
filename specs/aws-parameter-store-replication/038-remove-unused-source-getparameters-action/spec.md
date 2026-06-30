# Specification: Remove unused source-account `ssm:GetParameters` permission

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The Lambda source-account read policy currently grants both `ssm:GetParameter` and `ssm:GetParameters`. Runtime code uses `GetParameter` for source reads; the only `get_parameters` call is executed against destination clients after `AssumeRole`. Keeping unused source permissions expands role scope unnecessarily.

## Goal

Tighten least-privilege by removing unused `ssm:GetParameters` from the source execution role policy.

## Scope

- Update `modules/aws-parameter-store-replication/iam.tf` source read policy action list.
- Regenerate module `README.md` via `terraform-docs .` per repository workflow.
- Validate Terraform after the IAM policy change.

## Out of Scope

- Runtime code changes.
- Destination-role permission model changes.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Source read inline policy grants `ssm:GetParameter` (and conditional tag read) but no longer `ssm:GetParameters`.
- Module validation passes.
- README regeneration succeeds.
