# Specification: Unify manual and automatic parameter replication into one Lambda

**Date:** 2026-06-29
**Module:** `modules/aws-parameter-store-replication`

## Problem

The module currently deploys two separate Lambda functions and roles:
- automatic EventBridge-driven replication
- manual/API-driven replication (with optional full sync)

This duplicates packaging, IAM, outputs, and operational maintenance.

## Goal

Use a single replication Lambda that handles both invocation modes via event input (for example, an `initial_run` / `enable_full_sync` style flag), reducing module complexity while preserving current behavior.

## Scope

- Consolidate handlers into one entrypoint under module source.
- Consolidate Terraform Lambda resources into one function and one role.
- Keep EventBridge integration targeting the unified function.
- Preserve manual invocation capability for single-parameter replication and optional full sync.
- Provide backward-compatible outputs/variables where feasible (deprecate old names, avoid abrupt breakage).

## Out of Scope

- Destination-account IAM role creation.
- Changes to core replication semantics in `src/common/replication.py`.
- Any `CHANGELOG.md` changes.

## Acceptance Criteria

- Module deploys one Lambda function and one execution role.
- EventBridge automatic flow (Create/Update events) still works.
- Manual invocation with `parameter_name` still works.
- Full sync remains guarded by module config and explicit input flag.
- README/docs/examples reflect unified interface.
