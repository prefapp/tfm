# Specification: Update AWS provider constraint to v6 for aws-terraform-backend

**Date:** 2026-06-08
**Module:** `modules/aws-terraform-backend`
**Issue:** `#1290` (child of `#927`)

## Problem

The module currently pins the AWS provider to `~> 5.97.0` in `versions.tf`. Per the parent migration issue to AWS provider v6, this module must be updated to allow AWS provider major version 6.

Additionally, validation is blocked because `variables.tf` sets `variable "aws_region"` default using a data source reference (`data.aws_region.current.name`), which is invalid in Terraform variable defaults. The module also lacks the standard `.terraform-docs.yml` + `docs/{header,footer}.md` structure used by AWS modules in this repository.

## Goal

Update the module provider constraint from `~> 5.97.0` to `~> 6.40`, fix `variables.tf` so Terraform initialization is valid, and standardize module docs generation through `terraform-docs` following the AWS module pattern in this repository.

## Scope

- Update `modules/aws-terraform-backend/versions.tf` required provider version for `hashicorp/aws`.
- Fix invalid default in `modules/aws-terraform-backend/variables.tf` for `variable "aws_region"`.
- Add `.terraform-docs.yml` and `docs/header.md` + `docs/footer.md` to align with AWS module documentation structure.
- Regenerate `modules/aws-terraform-backend/README.md` via `terraform-docs .` (generated, not hand-edited) so requirements/providers sections reflect v6.
- Run formatting/validation checks relevant to the touched module.

## Out of Scope

- Functional refactors unrelated to AWS provider major version migration.
- Cross-module updates.
- Any `CHANGELOG.md` modification (handled by Release Please automation).

## Acceptance Criteria

- `modules/aws-terraform-backend/versions.tf` sets AWS provider constraint to `~> 6.40`.
- `modules/aws-terraform-backend/variables.tf` no longer uses a data source reference in variable defaults.
- Module contains `.terraform-docs.yml` and `docs/header.md` + `docs/footer.md`.
- `modules/aws-terraform-backend/README.md` reflects AWS provider v6 requirement.
- Formatting and validation checks for the module complete without errors.
