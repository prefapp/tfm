# Specification: Clarify existing_resources example wording for unified Lambda behavior

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The `existing_resources` example README described the Lambda as "automatic parameter replication", which is outdated now that the module provisions a single unified Lambda that supports both EventBridge-triggered and manual invocation.

## Goal

Align the `existing_resources` example wording with current module behavior to avoid confusion about deployed resources.

## Scope

- Capture the wording update in `modules/aws-parameter-store-replication/_examples/existing_resources/README.md` under "What it creates".
- Regenerate `modules/aws-parameter-store-replication/README.md` via `terraform-docs .` per repository documentation workflow.

## Out of Scope

- No Terraform runtime behavior changes.
- No IAM/resource logic changes.
- No `CHANGELOG.md` changes.

## Acceptance Criteria

- The Lambda bullet in the example uses unified invocation wording.
- Specs/plan/tasks clearly reflect this example-specific docs update.
- Diagnostics for modified files are clean.
