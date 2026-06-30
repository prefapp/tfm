# Specification: Rename destination assume-role inline policy to match its actual purpose

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The inline IAM policy resource is currently named `lambda_ssm_write_destinations` / `ssm-write-destinations`, but the policy grants only `sts:AssumeRole` on destination roles. The current name is misleading during IAM review, debugging, and Terraform resource inspection.

## Goal

Rename the inline policy resource and generated policy name so they clearly reflect their STS assume-role purpose.

## Scope

- Rename the Terraform resource in `modules/aws-parameter-store-replication/iam.tf`.
- Rename the generated inline policy `name` to use `sts-assume-destinations`.
- Regenerate `README.md` via `terraform-docs .` so the resources table reflects the new resource name.

## Out of Scope

- IAM permission changes.
- Runtime Python changes.
- Any `CHANGELOG.md` edits.

## Acceptance Criteria

- The Terraform resource name is updated from `lambda_ssm_write_destinations` to `lambda_sts_assume_destinations`.
- The inline policy `name` uses the `sts-assume-destinations` suffix.
- `README.md` is regenerated successfully.
- Diagnostics/validation pass for modified files.
