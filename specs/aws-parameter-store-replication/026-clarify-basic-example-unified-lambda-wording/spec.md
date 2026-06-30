# Specification: Clarify basic example wording for unified Lambda and optional EventBridge

**Date:** 2026-06-30
**Module:** `modules/aws-parameter-store-replication`

## Problem

The basic example README still describes the created Lambda as "automatic parameter replication", which is outdated now that the module deploys a single unified Lambda supporting both EventBridge-triggered and manual invocation. This can confuse readers about what is actually provisioned.

## Goal

Update the basic example wording so it accurately reflects the unified Lambda behavior and the optional nature of EventBridge in the example.

## Scope

- Update `modules/aws-parameter-store-replication/_examples/basic/README.md` wording in "What it creates".
- Regenerate `modules/aws-parameter-store-replication/README.md` via `terraform-docs .` per repository process.

## Out of Scope

- No Terraform code changes.
- No behavior/runtime changes.
- No `CHANGELOG.md` edits.

## Acceptance Criteria

- The Lambda bullet states unified EventBridge + manual invocation behavior.
- The EventBridge bullet explicitly calls it optional.
- Validation confirms modified files are error-free.
