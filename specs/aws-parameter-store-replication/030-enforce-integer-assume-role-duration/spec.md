# Specification: Enforce integer validation for assume_role_duration_seconds

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

`assume_role_duration_seconds` is validated only by range (`900..43200`) while typed as `number`. Non-integer values (for example `3600.5`) pass Terraform validation but are parsed as integer in the Lambda runtime, which can lead to fallback/default behavior and silent misconfiguration.

## Goal

Harden input validation so `assume_role_duration_seconds` must be an integer in the allowed range.

## Scope

- Update `variables.tf` validation for `assume_role_duration_seconds`.
- Keep variable type as `number` for compatibility, but enforce integer semantics in validation.
- Regenerate module `README.md` via `terraform-docs .`.

## Out of Scope

- Runtime logic changes.
- STS role/session policy changes.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Non-integer values such as `3600.5` are rejected by Terraform variable validation.
- Integers within `900..43200` are accepted.
- README regeneration succeeds.
