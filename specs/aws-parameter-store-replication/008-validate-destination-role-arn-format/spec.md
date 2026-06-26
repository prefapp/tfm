# Specification: Validate destination `role_arn` format

**Date:** 2026-06-26
**Module:** `modules/aws-parameter-store-replication`

## Problem

Current `destinations_json` validation only enforces non-empty `role_arn` values after `tostring(...)`. This allows invalid non-ARN values (for example booleans or numbers) to pass validation and fail later when generating/using IAM policy resources.

## Goal

Validate that each destination `role_arn` has IAM role ARN format during input validation.

## Scope

- Update `variables.tf` validation for `destinations_json.role_arn`
- Keep the rest of the schema validation unchanged

## Out of Scope

- Any IAM behavior/resource changes
- Any module API shape changes
- Any `CHANGELOG.md` updates

## Acceptance Criteria

- Validation rejects values not matching IAM role ARN format
- Validation continues to allow multiple destination entries
- Existing required-keys validation remains intact
