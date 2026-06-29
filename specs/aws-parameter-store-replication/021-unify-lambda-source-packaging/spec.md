# Specification: Unify Lambda source packaging strategy

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

`lambda.tf` currently includes both `src` and `src/common` in `source_path`. This works, but creates ambiguous import expectations (flat imports from `common` modules while also nesting `common/` inside `src`).

## Goal

Use a single packaging strategy based on `src` only, and update Python imports to explicit `common.*` module paths.

## Scope

- Update `lambda.tf` to include only `src` in `source_path`.
- Update Python imports in unified handler and common modules accordingly.

## Out of Scope

- Runtime behavior changes.
- IAM/infra behavior changes unrelated to packaging.
- Any `CHANGELOG.md` changes.

## Acceptance Criteria

- Lambda packaging references only `src`.
- Imports resolve via explicit `common.*` paths.
- Terraform and Python syntax validations pass.
