# Specification: Remove redundant `allowed_assume_roles` from module examples

**Date:** 2026-06-26
**Module:** `modules/aws-parameter-store-replication`

## Problem

The module examples under `_examples/` currently set `allowed_assume_roles` to the same destination role ARN already provided in `destinations_json`. Since destination `role_arn` values are always included in the generated `sts:AssumeRole` policy, this is redundant and can imply the setting is required.

## Goal

Update module examples to avoid redundant `allowed_assume_roles` entries that duplicate destination role ARNs.

## Scope

- Update `_examples/basic/main.tf`
- Update `_examples/existing_resources/main.tf`

## Out of Scope

- IAM behavior changes
- Module interface changes
- Any `CHANGELOG.md` updates

## Acceptance Criteria

- Example module blocks do not set `allowed_assume_roles` to duplicate destination role ARNs.
- Examples remain valid and focused on required/meaningful inputs.
- Module `README.md` is regenerated with `terraform-docs .` after example changes, following repository workflow.
