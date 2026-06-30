# Specification: Guard role ARN validation with map/object decode check

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The destination role ARN validation iterates over `jsondecode(var.destinations_json)` directly. If input decodes to a non-object/non-iterable shape, Terraform can raise an expression evaluation error instead of cleanly failing via existing validation messages.

## Goal

Restore a defensive `can(tomap(jsondecode(...)))` guard in the role ARN validation condition so evaluation is safe and failures are clean.

## Scope

- Update `variables.tf` role ARN validation condition.
- Regenerate module `README.md` via `terraform-docs .`.
- Validate module with `terraform validate`.

## Out of Scope

- Runtime code changes.
- IAM/resource logic changes.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- Role ARN validation condition includes map/object decode guard.
- Invalid non-object shapes fail cleanly through validations.
- `terraform validate` succeeds and docs are regenerated.
