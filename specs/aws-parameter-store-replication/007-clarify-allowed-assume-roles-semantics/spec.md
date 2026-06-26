# Specification: Clarify `allowed_assume_roles` semantics

**Date:** 2026-06-26
**Module:** `modules/aws-parameter-store-replication`

## Problem

The current variable description for `allowed_assume_roles` suggests it is the full list of roles the Lambda can assume. However, IAM policies also always include all destination `role_arn` entries from `destinations_json`.

This makes `allowed_assume_roles` effectively an additive list, not an allow-list, and can mislead consumers and IAM reviewers.

## Goal

Clarify the variable description so it accurately communicates that destination roles are always included and this variable adds extra assumable role ARNs.

## Scope

- Update `variables.tf` description for `allowed_assume_roles`
- Regenerate `README.md` via `terraform-docs .`

## Out of Scope

- Any IAM behavior changes
- Any change to `destinations_json` handling
- Any `CHANGELOG.md` edits

## Acceptance Criteria

- `allowed_assume_roles` description clearly states it is additional ARNs
- Description explicitly mentions destination `role_arn` values are always included
- Regenerated `README.md` reflects the updated input description
