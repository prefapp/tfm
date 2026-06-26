# Specification: Remove redundant `allowed_assume_roles` from usage examples

**Date:** 2026-06-26
**Module:** `modules/aws-parameter-store-replication`

## Problem

Current examples in `docs/header.md` include `allowed_assume_roles` populated with the same destination role ARNs already defined in `destinations_json`. Since module IAM policy logic always includes destination `role_arn` values, these example blocks can mislead users into thinking both lists must be kept in sync.

## Goal

Make examples reflect the default behavior by removing redundant `allowed_assume_roles` entries that duplicate destination role ARNs.

## Scope

- Update example snippets in `docs/header.md`
- Regenerate `README.md` with `terraform-docs .`

## Out of Scope

- Any IAM behavior changes
- Any variable/interface changes
- Any `CHANGELOG.md` edits

## Acceptance Criteria

- Basic and cross-account examples no longer require duplicate `allowed_assume_roles` entries for destination roles
- Regenerated README reflects updated examples
