# Specification: Configure STS AssumeRole DurationSeconds for destination clients

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

Destination SSM clients use assumed-role credentials with default STS session duration. Long-running or externally-orchestrated replication flows may benefit from explicit `DurationSeconds` control.

## Goal

Expose a module input for assumed-role session duration and apply it consistently in runtime assume-role calls.

## Scope

- Add Terraform input variable for assume-role duration seconds.
- Pass the value to Lambda as environment variable.
- Parse and use the value in Python runtime (`assume_role` calls).
- Document variable and behavior.

## Out of Scope

- Changing destination role max session duration (managed externally).
- Step Functions/chunking implementation.
- Any `CHANGELOG.md` changes.

## Acceptance Criteria

- New input variable available with safe default.
- Value is used by all destination role assumptions.
- Validation/docs updated and README regenerated.
- Diagnostics/syntax checks pass for changed files.
